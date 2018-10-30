# frozen_string_literal: true

class DropStatus < ActiveRecord::Migration[5.0]
  def up
    drop_table :statuses
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
