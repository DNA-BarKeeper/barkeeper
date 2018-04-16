class CreateJoinTableResponsibilityUser < ActiveRecord::Migration[5.0]
  def change
    create_join_table :responsibilities, :users do |t|
      t.index [:responsibility_id, :user_id]
    end
  end
end
