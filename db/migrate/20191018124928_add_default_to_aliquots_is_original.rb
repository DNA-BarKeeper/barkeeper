class AddDefaultToAliquotsIsOriginal < ActiveRecord::Migration[5.0]
  def change
    change_column :aliquots, :is_original, :boolean, :default => false
  end
end
