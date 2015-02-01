class AddCollectedToIndividuals < ActiveRecord::Migration
  def change
    add_column :individuals, :collected, :date
  end
end
