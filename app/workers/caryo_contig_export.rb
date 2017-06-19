class CaryoContigExport

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform

    ContigPdeUploader.new.create_uploaded_file

  end

end