# frozen_string_literal: true

module Import
  extend ActiveSupport::Concern

  # Opens +file+ as a spreadsheet depending on its file ending
  def open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::CSV.new(file.path)
    when '.xls' then Roo::Excel.new(file.path)
    when '.xlsx' then Roo::Excelx.new(file.path)
    when '.ods' then Roo::OpenOffice.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
