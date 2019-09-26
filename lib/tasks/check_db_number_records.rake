namespace :data do
  task check_db_number_records: :environment do
    isolates_sent_to_bonn = []

    Dir.foreach('sent_plates') do |item|
      next if File.directory?(item) # Also skips '.' and '..'

      CSV.foreach("sent_plates/#{item}", headers: true) do |row|
        isolates_sent_to_bonn << row['DNA Sample ID']
      end
    end

    isolates_sent_to_bonn = isolates_sent_to_bonn.flatten.collect { |id| id.downcase.gsub(' ', '') }.uniq

    puts "#{isolates_sent_to_bonn.size} unique Isolates were sent to Bonn."

    isolates_in_app = Isolate.in_project(5).map(&:dna_bank_id).compact.collect { |id| id.downcase.gsub(' ', '') }.uniq

    isolates_in_app = isolates_in_app & isolates_sent_to_bonn

    puts "#{isolates_in_app.size} of these Isolates were found in the web app."
    p isolates_in_app
  end
end