class AddHasIssueToIndividuals < ActiveRecord::Migration[5.0]
  def change
    add_column :individuals, :has_issue, :boolean
  end
end
