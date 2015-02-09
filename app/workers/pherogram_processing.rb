class PherogramProcessing

  include Sidekiq::Worker

  def perform(sp_id)


    sp=Species.find(sp_id)

    print sp.genus_name

  end
end