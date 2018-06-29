class ChangeAttributesOfIndividualSearch < ActiveRecord::Migration[5.0]
  def change
    add_reference :individual_searches, :project, foreign_key: true
    add_reference :individual_searches, :user, foreign_key: true

    change_column :individual_searches, :has_issue, 'integer USING CAST(has_issue AS integer)'
    change_column :individual_searches, :has_problematic_location, 'integer USING CAST(has_problematic_location AS integer)'
  end
end
