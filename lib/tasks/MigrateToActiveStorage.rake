namespace :data do
  task migrate_to_active_storage: :environment do
    require 'open-uri'

    # postgres
    get_blob_id = 'LASTVAL()'

    active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare('active_storage_blob_statement', <<-SQL)
    INSERT INTO active_storage_blobs (
      key, filename, content_type, metadata, byte_size, checksum, created_at
    ) VALUES ($1, $2, $3, '{}', $4, $5, $6)
    SQL

    active_storage_attachment_statement = ActiveRecord::Base.connection.raw_connection.prepare('active_storage_attachment_statement', <<-SQL)
    INSERT INTO active_storage_attachments (
      name, record_type, record_id, blob_id, created_at
    ) VALUES ($1, $2, $3, #{get_blob_id}, $4)
    SQL

    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    ActiveRecord::Base.transaction do
      models.each do |model|
        attachments = model.column_names.map do |c|
          if c =~ /(.+)_file_name$/
            $1
          end
        end.compact

        if attachments.blank?
          next
        end

        model.find_each.each do |instance|
          attachments.each do |attachment|
            if instance.send(attachment).path.blank?
              next
            end

            checksum = checksum(instance.send(attachment))

            if checksum
              ActiveRecord::Base.connection.raw_connection.exec_prepared(
                  'active_storage_blob_statement', [
                  key(instance),
                  instance.send("#{attachment}_file_name"),
                  instance.send("#{attachment}_content_type"),
                  instance.send("#{attachment}_file_size"),
                  checksum,
                  instance.updated_at.iso8601
              ])

              ActiveRecord::Base.connection.raw_connection.exec_prepared(
                  'active_storage_attachment_statement', [
                  attachment,
                  model.name,
                  instance.id,
                  instance.updated_at.iso8601,
              ])
            end
          end
        end
      end
    end
  end

  private

  def key(_instance)
    SecureRandom.uuid
  end

  def checksum(attachment)
    url = attachment.url.gsub('/system', 'https://gbol5.s3.amazonaws.com')

    begin
      Digest::MD5.base64digest(Net::HTTP.get(URI(url)))
    rescue Errno::ENOENT
      p attachment
      p url
    end
  end
end