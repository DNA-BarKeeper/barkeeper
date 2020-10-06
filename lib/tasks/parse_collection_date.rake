namespace :data do
  task parse_collection_date: :environment do
    individuals = Individual.where.not(collection_date: [nil, ''])
    cnt = 0

    individuals.each do |i|
      begin
        i.update(collected: Date.parse(i.collection_date))
        cnt += 1
      rescue ArgumentError
        puts "Date #{i.collection_date} is not a valid date (ID: #{i.id})."
      end
    end

    puts "#{cnt} of #{individuals.size} records were updated."
  end
end