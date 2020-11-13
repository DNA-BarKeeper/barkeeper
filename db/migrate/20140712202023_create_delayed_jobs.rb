#
# Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
# barcode data and metadata.
# Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of Barcode Workflow Manager.
#
# Barcode Workflow Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Barcode Workflow Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Barcode Workflow Manager.  If not, see
# <http://www.gnu.org/licenses/>.
#
# frozen_string_literal: true

class CreateDelayedJobs < ActiveRecord::Migration
  def self.up
    create_table :delayed_jobs, force: true do |table|
      table.integer  :priority, default: 0, null: false # Allows some jobs to jump to the front of the queue
      table.integer  :attempts, default: 0, null: false # Provides for retries, but still fail eventually.
      table.text     :handler, null: false # YAML-encoded string of the object that will do work
      table.text     :last_error                              # reason for last failure (See Note below)
      table.datetime :run_at                                  # When to run. Could be Time.zone.now for immediately, or sometime in the future.
      table.datetime :locked_at                               # Set when a client is working on this object
      table.datetime :failed_at                               # Set when all retries have failed (actually, by default, the record is deleted instead)
      table.string   :locked_by                               # Who is working on this object (if locked)
      table.string   :queue                                   # The name of the queue this job is in
      table.timestamps
    end

    add_index :delayed_jobs, %i[priority run_at], name: 'delayed_jobs_priority'
  end

  def self.down
    drop_table :delayed_jobs
  end
end
