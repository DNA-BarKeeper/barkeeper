class AddMicronicTubeToAliquots < ActiveRecord::Migration[5.0]
  def change
    add_column :aliquots, :micronic_tube, :string
  end
end
