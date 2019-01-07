# frozen_string_literal: true

Paperclip.options[:content_type_mappings] = {
    scf: 'application/octet-stream',
    ab1: 'application/octet-stream',
    fq: 'text/plain',
    fastq: 'text/plain',
    fasta: 'text/plain',
    xls: ['text/xml', 'application/excel', 'application/vnd.ms-excel', 'application/xml']
    # :xls => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
}
