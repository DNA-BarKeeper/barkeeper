set :output, "#{path}/log/cron.log"

every 1.day, :at => '1:30 am' do
  rake "data:create_xls" # Create Specimen.xls file from current database
end

every 1.day, :at => '2:30 am' do
  rake "data:remove_old_searches" # Delete all untitled contig searches older than a month
end