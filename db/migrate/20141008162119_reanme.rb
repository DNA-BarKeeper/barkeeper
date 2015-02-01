class Reanme < ActiveRecord::Migration
  def change
    rename_column :isolates, :DNA_bank_id, :dna_bank_id
  end
end
