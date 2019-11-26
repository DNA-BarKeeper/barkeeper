# frozen_string_literal: true

class RenameCopyToIsolate < ActiveRecord::Migration
  def change
    rename_table :copies, :isolates
  end
end
