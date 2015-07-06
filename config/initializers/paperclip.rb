Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
Paperclip::Attachment.default_options[:path] = '/:class/:attachment/:id_partition/:style/:filename'

Paperclip.options[:content_type_mappings] = {
    :scf => "application/octet-stream",
    :ab1 => "application/octet-stream"
    # :xls => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
}