namespace :data do

  desc 'Refesh overview materialized views'
  task :refresh_matviews => :environment do
    OverviewAllTaxaMatview.refresh
    OverviewFinishedTaxaMatview.refresh
  end

end