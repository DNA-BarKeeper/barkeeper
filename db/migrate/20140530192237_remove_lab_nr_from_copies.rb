# frozen_string_literal: true

class RemoveLabNrFromCopies < ActiveRecord::Migration
  def change
    remove_column :copies, :lab_nr, :integer
    add_column :copies, :lab_nr, :string
  end
end
