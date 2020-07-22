# frozen_string_literal: true

class TxtUploader < ApplicationRecord
  has_one_attached :uploaded_file
  # ,
  #                   path: '/output.txt'

  # # Validate content type
  # validates_attachment_content_type :uploaded_file, content_type: /\Atext\/plain/
  #
  # # Validate filename
  # validates_attachment_file_name :uploaded_file, matches: [/txt\Z/]

  def create_uploaded_file(text)
    file_to_upload = File.open('output.txt', 'w')

    file_to_upload.write(text)
    file_to_upload.close

    self.uploaded_file.attach(io: File.open('output.txt'), filename: 'output.txt', content_type: 'text/plain')
    save!
  end
end
