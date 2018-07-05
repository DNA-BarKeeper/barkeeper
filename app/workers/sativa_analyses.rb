class SativaAnalyses
  include Sidekiq::Worker

  require 'net/ssh'
  require 'net/scp'

  sidekiq_options retry: false

  def perform()
    Marker.gbol_marker.each do |marker|
      puts "Checking if analysis is necessary for #{marker.name}..."
      last_analysis = MislabelAnalysis.where(automatic: true, marker: marker).order(created_at: :desc).first
      count = -1

      if last_analysis
        count = MarkerSequence.where(marker_id: marker.id).where("marker_sequences.updated_at >= ?", last_analysis.created_at).size
      end

      analyse_on_server(marker) if (count > 50) || (count == -1) # More than 50 new seqs OR no analysis was done before
    end
  end

  private

  def analyse_on_server(marker)
    min_lengths = { 'trnLF': 516, 'ITS': 485, 'rpl16': 580, 'trnK-matK': 1188 }
    marker_name = marker.name

    puts "#{current_time}: Starting analysis for marker '#{marker.name}'..."
    search = MarkerSequenceSearch.create(has_species: true, has_warnings: 'both', marker: marker_name, project_id: 5, min_length: min_lengths[marker_name.to_sym])

    title = "all_taxa_#{marker_name}_#{search.created_at.to_date.to_s}"
    sequences = "#{Rails.root}/#{title}.fasta"
    tax_file = "#{Rails.root}/#{title}.tax"

    puts "#{current_time}: Creating FASTA and taxon file..."
    File.open(sequences, "w+") do |f|
      f.write(search.as_fasta(false))
    end

    File.open(tax_file, "w+") do |f|
      f.write(search.taxon_file)
    end

    puts "#{current_time}: Establishing SSH connection to Xylocalyx..."
    Net::SSH.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/gbol_xylocalyx']) do |session|
      analysis_dir = "/data/data1/sarah/SATIVA/#{title}"

      puts "#{current_time}: Creating analysis directory..."
      session.exec!("mkdir #{analysis_dir}")

      puts "#{current_time}: Uploading analysis input files..."
      session.scp.upload! tax_file, analysis_dir
      session.scp.upload! sequences, analysis_dir

      puts "#{current_time}: Creating alignment with MAFFT..."
      alignment = "#{analysis_dir}/#{title}_mafft.fasta"
      output = session.exec!("mafft --thread 50 --maxiterate 1000 #{analysis_dir}/#{title}.fasta > #{alignment}")
      puts output
    end

    # Start new connection in case task took too long and SSH connection timed out
    Net::SSH.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/gbol_xylocalyx']) do |session|
      puts "#{current_time}: Running SATIVA analysis..."
      output = session.exec!("cd #{analysis_dir} && python /home/kai/sativa-master/sativa.py -s '#{alignment}' -t '#{title}.tax' -x BOT -T 50")
      puts output

      puts "#{current_time}: Downloading analysis results..."
      session.scp.download! "#{analysis_dir}/#{title}.mis", "#{Rails.root}/#{title}.mis"
    end

    results = File.new("#{Rails.root}/#{title}.mis")
    MislabelAnalysis.import(results, title, search.marker_sequences.size, marker.id, true)

    puts "#{current_time}: Deleting local files...\n"
    FileUtils.rm(sequences)
    FileUtils.rm(tax_file)
    FileUtils.rm(results)

    puts "Finished analysis at #{current_time}."
  end

  def current_time
    Time.now.strftime("%H:%M:%S")
  end
end