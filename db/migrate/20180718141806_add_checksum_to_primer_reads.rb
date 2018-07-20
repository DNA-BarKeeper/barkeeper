class AddChecksumToPrimerReads < ActiveRecord::Migration[5.0]
  def change
    add_column :primer_reads, :chromatogram_fingerprint, :string
  end
end
