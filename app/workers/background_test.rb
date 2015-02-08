class BackgroundTest
  include Sidekiq::Worker

  def perform(species_name)
    100.times do
      print "#{species_name} - testing background task!"
    end
  end
end