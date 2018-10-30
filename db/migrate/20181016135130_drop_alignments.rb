# frozen_string_literal: true

class DropAlignments < ActiveRecord::Migration[5.0]
  def up
    drop_table :alignments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
