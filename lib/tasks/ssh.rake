namespace :data do
  require 'net/ssh'
  require 'net/scp'

  task :ssh_gbol5 => :environment do
    Net::SSH.start('gbol5.de', 'sarah', port: 1694) do |session|
      output = session.exec!('hostname')
      puts output
    end
  end

  desc 'Check how many sequences were created or updated since last analysis and redo analysis if necessary'
  task :check_new_marker_sequences => :environment do
    Marker.gbol_marker.each do |marker|
      last_analysis_timestamp = MislabelAnalysis.where(automatic: true, marker: marker).order(created_at: :desc).first.created_at
      count = MarkerSequence.where(marker_id: marker.id).where("marker_sequences.updated_at >= ?", last_analysis_timestamp).size

      analyse_on_server(marker) if (count > 50)
    end
  end

  private

  def analyse_on_server(marker)
    search = MarkerSequenceSearch.create(has_species: true, has_warnings: 'both', marker: marker, project_id: 5)

    title = "all_taxa_#{marker.name}_#{search.created_at.to_date.to_s}"
    sequences = "#{Rails.root}/#{title}.fasta"
    tax_file = "#{Rails.root}/#{title}.tax"

    puts 'Creating FASTA and taxon file...'
    File.open(sequences, "w+") do |f|
      f.write(search.as_fasta(false))
    end

    File.open(tax_file, "w+") do |f|
      f.write(search.taxon_file)
    end

    puts 'Establishing SSH connection to Xylocalyx...'
    Net::SSH.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/xylocalyx']) do |session| # TODO: use key gbol_xylocalyx
      analysis_dir = "/data/data1/sarah/SATIVA/#{title}"

      puts 'Creating analysis directory...'
      session.exec!("mkdir #{analysis_dir}")

      puts 'Uploading analysis input files...'
      session.scp.upload! tax_file, analysis_dir
      session.scp.upload! sequences, analysis_dir

      # TODO: Create alignment on server
      alignment = '/media/sarah/Data/Sarah/Dokumente/SATIVA/all_taxa/trnLF/all_taxa_trnLF_mafft.fasta'
      session.scp.upload! alignment, analysis_dir
      alignment = "#{analysis_dir}/#{title}_mafft.fasta"
      # session.exec!("mafft #{analysis_dir}/#{title}.fasta > #{alignment}")

      puts 'Running SATIVA analysis...'
      output = session.exec!("cd #{analysis_dir} && python /home/kai/sativa-master/sativa.py -s '#{alignment}' -t '#{title}.tax' -x BOT -T 50")
      puts output

      puts 'Downloading analysis results...'
      session.scp.download! "#{analysis_dir}/#{title}.mis", "#{Rails.root}/#{title}.mis"
    end

    results = File.new("#{Rails.root}/#{title}.mis")
    MislabelAnalysis.import(results, title, marker.id, true)

    puts 'Deleting local files...'
    FileUtils.rm(sequences)
    FileUtils.rm(tax_file)
    FileUtils.rm(results)
  end
end