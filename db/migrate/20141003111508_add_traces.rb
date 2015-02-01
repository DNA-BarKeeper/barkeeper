class AddTraces < ActiveRecord::Migration
  def change
    add_column :primer_reads, :atrace, :integer, array: true
    add_column :primer_reads, :ctrace, :integer, array: true
    add_column :primer_reads, :gtrace, :integer, array: true
    add_column :primer_reads, :ttrace, :integer, array: true
    add_column :primer_reads, :peak_indices, :integer, array: true
  end
end
