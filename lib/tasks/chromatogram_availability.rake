# frozen_string_literal: true

namespace :data do
  desc 'Check if chromatogram file is available on S3'
  task chromatogram_availability: :environment do
    log = File.open("chromatogram_availability_log.txt", 'w')

    cnt = 0
    PrimerRead.all.with_attached_chromatogram.find_each do |pr|
      begin
        pr.chromatogram.blob.download
        print '.'
      rescue Aws::S3::Errors::NoSuchKey
        cnt += 1
        print '!'
        log.puts(pr.name)
      end
    end

    log.puts("No chromatogram file could be found on S3 for #{cnt} primer reads.")
    puts "Finished."
  end
end
