namespace :data do
  require 'net/ssh'
  require 'net/scp'
  require 'net/sftp'

  desc 'Check how many sequences were created or updated since last analysis and redo analysis if necessary'
  task :check_new_marker_sequences => :environment do
    # TODO: Do analyses for all existing projects (except all_records)
    Marker.gbol_marker.each do |marker|
      puts "Checking if analysis is necessary for #{marker.name}..."
      last_analysis = MislabelAnalysis.where(automatic: true, marker: marker).order(created_at: :desc).first
      count = -1

      if last_analysis
        count = MarkerSequence.where(marker_id: marker.id).where('marker_sequences.updated_at >= ?', last_analysis.created_at).size
      end

      analyse_on_server(marker) if (count > 50) || (count == -1) # More than 50 new seqs OR no analysis was done before
    end
  end

  desc 'Check if recent SATIVA results exist and download them'
  task :download_sativa_results => :environment do
    Marker.gbol_marker.each do |marker|
      puts "Checking if analysis results exist for #{marker.name}..."

      exists = false
      title = "all_taxa_#{marker.name}_#{Time.now.to_date}"
      analysis_dir = "/data/data1/sarah/SATIVA/#{title}"

      # Checks if file exists before download
      Net::SFTP.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/gbol_xylocalyx']) do |sftp|
        sftp.stat("#{analysis_dir}/#{title}.mis") do |response|
          if response.ok?
            puts "#{current_time}: Downloading result file..."
            sftp.download!("#{analysis_dir}/#{title}.mis", "#{Rails.root}/#{title}.mis")
            exists = true
          end
        end
      end

      next unless exists
      results = File.new("#{Rails.root}/#{title}.mis")
      search = MarkerSequenceSearch.where(has_species: true, has_warnings: 'both', marker: marker.name, project_id: 5, created_at: Time.now.beginning_of_day..Time.now.end_of_day).first

      puts "#{current_time}: Importing analysis results..."
      MislabelAnalysis.import(results, title, search.marker_sequences.size, marker.id, true)

      FileUtils.rm(results)
    end

    puts "#{current_time}: Done.\n"
  end

  private

  def analyse_on_server(marker)
    marker_name = marker.name

    puts "#{current_time}: Starting analysis for marker '#{marker.name}'..."
    search = MarkerSequenceSearch.create(has_species: true, has_warnings: 'both', marker: marker_name, project_id: 5)

    title = "all_taxa_#{marker_name}_#{search.created_at.to_date}"
    sequences = "#{Rails.root}/#{title}.fasta"
    tax_file = "#{Rails.root}/#{title}.tax"

    analysis_dir = "/data/data1/sarah/SATIVA/#{title}"
    alignment = "#{analysis_dir}/#{title}_mafft.fasta"

    puts "#{current_time}: Creating FASTA and taxon file..."
    File.open(sequences, 'w+') do |f|
      f.write(search.analysis_fasta(true))
    end

    File.open(tax_file, 'w+') do |f|
      f.write(search.taxon_file(true))
    end

    puts "#{current_time}: Establishing SSH connection to Xylocalyx..."
    Net::SSH.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/gbol_xylocalyx']) do |session|
      puts "#{current_time}: Creating analysis directory..."
      session.exec!("mkdir #{analysis_dir}")

      puts "#{current_time}: Uploading analysis input files..."
      session.scp.upload! tax_file, analysis_dir
      session.scp.upload! sequences, analysis_dir

      puts "#{current_time}: Deleting local files..."
      FileUtils.rm(sequences)
      FileUtils.rm(tax_file)

      puts "#{current_time}: Creating alignment with MAFFT..."
      output = session.exec!("mafft --thread 10 --maxiterate 1000 #{analysis_dir}/#{title}.fasta > #{alignment}")
      puts output
    end

    # Start new connection in case task took too long and SSH connection timed out
    Net::SSH.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/gbol_xylocalyx']) do |session|
      puts "#{current_time}: Running SATIVA analysis..."
      output = session.exec!("cd #{analysis_dir} && python /home/kai/sativa-master/sativa.py -s '#{alignment}' -t '#{title}.tax' -x BOT -T 10")
      puts output
    end

    puts "Finished analysis at #{current_time}.\n"
  end

  def current_time
    Time.now.strftime('%H:%M:%S')
  end
end