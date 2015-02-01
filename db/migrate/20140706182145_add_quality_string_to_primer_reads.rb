class AddQualityStringToPrimerReads < ActiveRecord::Migration
  def change
    add_column :primer_reads, :quality_string, :text
  end
end
