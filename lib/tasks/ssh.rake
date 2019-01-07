# frozen_string_literal: true

namespace :data do
  require 'net/ssh'
  require 'net/scp'
  require 'net/sftp'

  desc 'Check how many sequences were created or updated since last analysis and redo analysis if necessary'
  task check_new_marker_sequences: :environment do
    # TODO: Do analyses for all existing projects (except all_records)
    Marker.gbol_marker.each do |marker|
      # Check if analysis is necessary for marker
      last_analysis = MislabelAnalysis.where(automatic: true, marker: marker).order(created_at: :desc).first
      count = -1

      if last_analysis
        count = MarkerSequence.where(marker_id: marker.id).where('marker_sequences.updated_at >= ?', last_analysis.created_at).size
      end

      analyse_on_server(marker) if (count > 50) || (count == -1) # More than 50 new seqs OR no analysis was done before
    end
  end

  desc 'Check if recent SATIVA results exist and download them'
  task download_sativa_results: :environment do
    Marker.gbol_marker.each do |marker|
      exists = false
      title = "all_taxa_#{marker.name}_#{Time.now.to_date}"
      analysis_dir = "/data/data1/sarah/SATIVA/#{title}"

      # Checks if file exists before download
      Net::SFTP.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/gbol_xylocalyx']) do |sftp|
        sftp.stat("#{analysis_dir}/#{title}.mis") do |response|
          if response.ok?
            # Download result file
            sftp.download!("#{analysis_dir}/#{title}.mis", "#{Rails.root}/#{title}.mis")
            exists = true
          end
        end
      end

      next unless exists
      results = File.new("#{Rails.root}/#{title}.mis")
      search = MarkerSequenceSearch.where(has_species: true, has_warnings: 'both', marker: marker.name, project_id: 5, created_at: Time.now.beginning_of_day..Time.now.end_of_day).first

      # Import analysis result
      MislabelAnalysis.import(results, title, search.marker_sequences.size, marker.id, true)

      FileUtils.rm(results)
    end
  end

  private

  def analyse_on_server(marker)
    marker_name = marker.name
    search = MarkerSequenceSearch.create(has_species: true, has_warnings: 'both', marker: marker_name, project_id: 5)

    title = "all_taxa_#{marker_name}_#{search.created_at.to_date}"

    sequences = "#{Rails.root}/#{title}.fasta"
    tax_file = "#{Rails.root}/#{title}.tax"

    analysis_dir = "/data/data1/sarah/SATIVA/#{title}"

    File.open(sequences, 'w+') do |f|
      f.write(search.analysis_fasta(true))
    end

    File.open(tax_file, 'w+') do |f|
      f.write(search.taxon_file(true))
    end

    Net::SSH.start('xylocalyx.uni-muenster.de', 'kai', keys: ['/home/sarah/.ssh/gbol_xylocalyx']) do |session|
      # Create analysis directory
      session.exec!("mkdir #{analysis_dir}")

      # Upload analysis input files
      session.scp.upload! tax_file, analysis_dir
      session.scp.upload! sequences, analysis_dir

      # Delete local files
      FileUtils.rm(sequences)
      FileUtils.rm(tax_file)

      # Start analysis on server
      session.exec!("/home/kai/analysis-scripts/SATIVA.sh #{title}")
    end
  end
end
