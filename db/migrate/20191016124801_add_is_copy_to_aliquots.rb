class AddIsCopyToAliquots < ActiveRecord::Migration[5.0]
  def change
    add_column :aliquots, :is_copy, :boolean
  end
end
