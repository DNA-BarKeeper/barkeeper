# frozen_string_literal: true

class AddGbolIsolationNrToIsolates < ActiveRecord::Migration
  def change
    add_column :isolates, :gbol_isolation_nr, :string
  end
end
