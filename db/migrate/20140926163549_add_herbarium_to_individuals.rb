# frozen_string_literal: true

class AddHerbariumToIndividuals < ActiveRecord::Migration
  def change
    add_column :individuals, :herbarium, :string
    add_column :individuals, :voucher, :string
    add_column :individuals, :country, :string
    add_column :individuals, :state_province, :string
    add_column :individuals, :locality, :text
    add_column :individuals, :latitude, :string
    add_column :individuals, :longitude, :string
    add_column :individuals, :elevation, :string
    add_column :individuals, :exposition, :string
    add_column :individuals, :habitat, :text
    add_column :individuals, :substrate, :string
    add_column :individuals, :life_form, :string
    add_column :individuals, :collection_nr, :string
    add_column :individuals, :collection_date, :string
    add_column :individuals, :determination, :string
    add_column :individuals, :revision, :string
    add_column :individuals, :confirmation, :string
    add_column :individuals, :comments, :text
  end
end
