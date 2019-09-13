class RemoveVoucherFromIndividual < ActiveRecord::Migration[5.0]
  def change
    remove_column :individuals, :voucher, :string
  end
end
