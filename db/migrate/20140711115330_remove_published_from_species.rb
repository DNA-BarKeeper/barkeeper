class RemovePublishedFromSpecies < ActiveRecord::Migration
  def change
    remove_column :species, :published, :date
  end
end
