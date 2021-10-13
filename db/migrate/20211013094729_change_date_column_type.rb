class ChangeDateColumnType < ActiveRecord::Migration[5.2]
  def change
    change_column :contigs, :verified_at, :date
    change_column :isolates, :isolation_date, :date
    change_column :mislabels, :solved_at, :date
    change_column :projects, :start, :date
    change_column :projects, :due, :date
  end
end
