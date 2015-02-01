class AddDnabank < ActiveRecord::Migration
  def change
    add_column :isolates, :DNA_bank_id, :string
  end
end
