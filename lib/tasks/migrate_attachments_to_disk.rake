namespace :migrate_attachments do
  desc 'Ensures all files are mirrored'
  task mirror_all: [:environment] do
    # All services in our rails configuration
    all_services = [ActiveStorage::Blob.service.primary, *ActiveStorage::Blob.service.mirrors]

    # Iterate through each blob
    ActiveStorage::Blob.all.each do |blob|

      # Select services where file exists
      services = all_services.select { |file| file.exist? blob.key }

      # Skip blob if file doesn't exist anywhere
      next unless services.present?

      # Select services where file doesn't exist
      mirrors = all_services - services

      # Open the local file (if one exists)
      local_file = File.open(services.find{ |service| service.is_a? ActiveStorage::Service::DiskService }.path_for blob.key) if services.select{ |service| service.is_a? ActiveStorage::Service::DiskService }.any?

      # Upload local file to mirrors (if one exists)
      mirrors.each do |mirror|
        mirror.upload blob.key, local_file, checksum: blob.checksum
      end if local_file.present?

      # If no local file exists then download a remote file and upload it to the mirrors (thanks @Rystraum)
      if !local_file.present?
        temp_file = Tempfile.open(binmode: true) { |tempfile| tempfile << services.first.download(blob.key) }

        mirrors.each do |mirror|
          mirror.upload blob.key, File.open(temp_file.path), checksum: blob.checksum
        end
      end
    end
  end
end
