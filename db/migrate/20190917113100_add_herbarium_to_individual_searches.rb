class AddHerbariumToIndividualSearches < ActiveRecord::Migration[5.0]
  def change
    add_column :individual_searches, :herbarium, :string
  end
end
