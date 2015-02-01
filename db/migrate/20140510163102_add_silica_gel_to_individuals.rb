class AddSilicaGelToIndividuals < ActiveRecord::Migration
  def change
    add_column :individuals, :silica_gel, :boolean
  end
end
