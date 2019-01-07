# frozen_string_literal: true

class AddSolvedToMislabels < ActiveRecord::Migration[5.0]
  def change
    add_column :mislabels, :solved, :boolean, default: false
    add_column :mislabels, :solved_by, :integer
    add_column :mislabels, :solved_at, :datetime
  end
end
