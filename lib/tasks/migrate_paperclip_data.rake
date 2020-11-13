#
# Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
# barcode data and metadata.
# Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of Barcode Workflow Manager.
#
# Barcode Workflow Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Barcode Workflow Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Barcode Workflow Manager.  If not, see
# <http://www.gnu.org/licenses/>.
#
require 'open-uri'

namespace :migrate_paperclip do
  desc 'Migrate the paperclip data'
  task move_data: :environment do
    # Prepare the insert statements
    prepare_statements

    # Eager load the application so that all Models are available
    Rails.application.eager_load!

    # Get a list of all the models in the application
    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    # Loop through all the models found
    models.each do |model|
      puts 'Checking Model [' + model.to_s + '] for Paperclip attachment columns ...'

      # If the model has a column or columns named *_file_name,
      # We are assuming this is a column added by Paperclip.
      # Store the name of the attachment(s) found (e.g. "avatar") in an array named attachments
      attachments = model.column_names.map do |c|
        Regexp.last_match(1) if c =~ /(.+)_file_name$/
      end.compact

      # If no Paperclip columns were found in this model, go to the next model
      if attachments.blank?
        puts '  No Paperclip attachment columns found for [' + model.to_s + '].'
        puts ''
        next
      end

      puts '  Paperclip attachment columns found for [' + model.to_s + ']: ' + attachments.to_s

      # Loop through the records of the model, and then through each attachment definition within the model
      model.find_each.each do |instance|
        attachments.each do |attachment|
          # If the model record doesn't have an uploaded attachment, skip to the next record
          next if instance.send(attachment).path.blank?

          # Otherwise, we will convert the Paperclip data to ActiveStorage records
          create_active_storage_records(instance, attachment, model)
        end
      end
      puts ''
    end
  end
end

private

def prepare_statements
  # Get the id of the last record inserted into active_storage_blobs
  # This will be used in the insert to active_storage_attachments
  # Postgres
  get_blob_id = 'LASTVAL()'

  # Prepare two insert statements for the new ActiveStorage tables
  ActiveRecord::Base.connection.raw_connection.prepare('active_storage_blob_statement', <<-SQL)
    INSERT INTO active_storage_blobs (
      key, filename, content_type, metadata, byte_size, checksum, created_at
    ) VALUES ($1, $2, $3, '{}', $4, $5, $6)
  SQL

  ActiveRecord::Base.connection.raw_connection.prepare('active_storage_attachment_statement', <<-SQL)
    INSERT INTO active_storage_attachments (
      name, record_type, record_id, blob_id, created_at
    ) VALUES ($1, $2, $3, #{get_blob_id}, $4)
  SQL
end

def create_active_storage_records(instance, attachment, model)
  puts '    Creating ActiveStorage records for [' +
           model.name + ' (ID: ' + instance.id.to_s + ')] ' +
           instance.send("#{attachment}_file_name") +
           ' (' + instance.send("#{attachment}_content_type") + ')'

  build_active_storage_blob(instance, attachment)
  build_active_storage_attachment(instance, attachment, model)
end

def build_active_storage_blob(instance, attachment)
  # Set the values for the new ActiveStorage records based on the data from Paperclip's fields
  # for active_storage_blobs
  created_at = instance.updated_at.iso8601
  blob_key = key(instance, attachment)
  filename = instance.send("#{attachment}_file_name")
  content_type = instance.send("#{attachment}_content_type")
  file_size = instance.send("#{attachment}_file_size")
  file_checksum = checksum(instance.send(attachment))

  blob_values = [blob_key, filename, content_type, file_size, file_checksum, created_at]

  # Insert the converted blob record into active_storage_blobs
  insert_record('active_storage_blob_statement', blob_values)
end

def build_active_storage_attachment(instance, attachment, model)
  # Set the values for the new ActiveStorage records based on the data from Paperclip's fields
  # for active_storage_attachments
  created_at = instance.updated_at.iso8601
  blob_name = attachment
  record_type = model.name
  record_id = instance.id

  attachment_values = [blob_name, record_type, record_id, created_at]

  # Insert the converted attachment record into active_storage_attachments
  insert_record('active_storage_attachment_statement', attachment_values)
end

def insert_record(statement, values)
  ActiveRecord::Base.connection.raw_connection.exec_prepared(
      statement,
      values
  )
end

def key(instance, attachment)
  SecureRandom.uuid
  # Alternatively:
  # instance.send("#{attachment}_file_name")
end

def checksum(attachment)
  # Get a checksum for the file (required for ActiveStorage)

  # remote files stored on a cloud service:
  url = Rails.env.production? ? 'https:' + attachment.url : attachment.url.gsub('/system', 'https://gbol5.s3.amazonaws.com')
  Digest::MD5.base64digest(Net::HTTP.get(URI(url)))
end
