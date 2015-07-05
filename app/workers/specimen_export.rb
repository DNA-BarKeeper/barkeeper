class SpecimenExport

  include Sidekiq::Worker

  def perform

    # get all indiv.
    @individuals=Individual.includes(:species => :family).all

    xml_file = XmlUploader.new
    xml_file.create_uploaded_file

  end

end