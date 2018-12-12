# frozen_string_literal: true

Paperclip.options[:content_type_mappings] = {
  scf: 'application/octet-stream',
  ab1: 'application/octet-stream',
  # :xls => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  xls: ['text/xml', 'application/excel', 'application/vnd.ms-excel', 'application/xml']
}
