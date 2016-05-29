class AddPartialConsCountToContigs < ActiveRecord::Migration
  def change
    add_column :contigs, :partial_cons_count, :integer
  end
end
