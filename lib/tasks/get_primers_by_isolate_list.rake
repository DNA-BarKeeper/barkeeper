namespace :data do
  task get_primer_by_isolate_list: :environment do
    isolate_file = File.open("isolate_list_dietmar.txt", 'r')
    isolates = isolate_file.readlines.map(&:chomp)
    isolates.delete('')
    isolates.delete(' ')

    CSV.open("primer_list.csv", 'w') do |csv|
      csv << ['isolate', 'primer read', 'primer']

      isolates.each do |isolate_name|
        isolate = Isolate.find_by_lab_isolation_nr(isolate_name)
        if isolate
          contigs = isolate.contigs.where(marker_id: 7) # trnK-matK

          contigs.each do |contig|
            contig.primer_reads.each do |read|
              csv << [isolate_name, read.name, read.primer&.name]
            end
          end
        end
      end
    end
  end
end