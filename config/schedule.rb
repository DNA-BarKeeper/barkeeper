# frozen_string_literal: true

set :output, "#{path}/log/cron.log"

# Whenever config
if defined? rbenv_root
  job_type :rake,    %(cd :path && :environment_variable=:environment :rbenv_root/bin/rbenv exec bundle exec rake :task --silent :output)
  job_type :runner,  %(cd :path && :rbenv_root/bin/rbenv exec bundle exec rails runner -e :environment ':task' :output)
  job_type :script,  %(cd :path && :environment_variable=:environment :rbenv_root/bin/rbenv exec bundle exec script/:task :output)
end

every 1.day, at: '11:30 pm' do
  rake 'data:create_xls' # Create Specimen.xls file from current database
end

every 1.day, at: '0:30 am' do
  rake 'data:remove_old_searches' # Delete all untitled contig searches older than a month
end

every 1.day, at: '9:00 pm' do
  rake 'data:check_new_marker_sequences' # Checks amount of new/updated sequences and runs SATIVA analysis if necessary
end

every 1.day, at: '3:10 am' do
  rake 'data:flag_specimen' # Places a warning on specimens with multiple sequences that have issues
end

every 1.day, at: '3:15 am' do
  rake 'data:unflag_specimen' # Removes warnings from specimens with less than two sequences that have issues
end
