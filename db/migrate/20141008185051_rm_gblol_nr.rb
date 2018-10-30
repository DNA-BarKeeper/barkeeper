# frozen_string_literal: true

class RmGblolNr < ActiveRecord::Migration
  def change
    remove_column :isolates, :gbol_isolation_nr
  end
end
