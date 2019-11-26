class RenameIsCopyInTableAliquots < ActiveRecord::Migration[5.0]
  def change
    rename_column :aliquots, :is_copy, :is_original
  end
end
