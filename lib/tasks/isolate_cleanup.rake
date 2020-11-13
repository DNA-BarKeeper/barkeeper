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
namespace :data do
  task move_isolate_names_to_correct_fields: :environment do
    isolates = Isolate.where('lab_isolation_nr ilike ?', "DB%").where(dna_bank_id: ['', nil])
    isolates.all.each { |isolate| isolate.update(dna_bank_id: isolate.lab_isolation_nr) }

    puts "#{isolates.size} DB numbers were moved to the correct field."
  end

  task find_duplicate_db_numbers: :environment do
    names_with_multiple = Isolate.group(:dna_bank_id).having('count(dna_bank_id) > 1').count.keys
    isolates = Isolate.where(dna_bank_id: names_with_multiple)

    #TODO: Maybe create CSV with GBOL numbers and/or other info for Berlin
    puts "#{isolates.size} Isolates with #{names_with_multiple.size} duplicate DNA Bank numbers were found."
  end

  task import_db_gbol_assignments: :environment do
    cnt = 0
    not_found = 0

    Dir.foreach('db_gbol_assignments') do |item|
      next if File.directory?(item) # Also skips '.' and '..'
      next unless File.extname(item) == ".csv" # Read only CSV files

      CSV.foreach("db_gbol_assignments/#{item}", headers: true) do |row|
        gbol = row['Nr.']
        db = row['Isolate']

        if gbol && db
          isolate = Isolate.find_by("LOWER(lab_isolation_nr) = ?", gbol.downcase) # Case insensitive search
          not_found += 1 unless isolate
          cnt += 1 if isolate && !isolate.dna_bank_id
          isolate.update(dna_bank_id: db) if isolate && !isolate.dna_bank_id # Isolate was found and has no DB number yet
        end
      end
    end

    puts "#{cnt} DB numbers were assigned to isolates based on their GBOL numbers. #{not_found} Isolates could not be found in the database."
    puts "Done."
  end

  task isolate_table_check: :environment do
    suspicious_columns = %w(comment_copy comment_orig concentration_copy concentration_orig concentration lab_id_copy lab_id_orig
micronic_plate_id_copy micronic_plate_id_orig micronic_plate_id micronic_tube_id_copy micronic_tube_id_orig micronic_tube_id
well_pos_micronic_plate_copy well_pos_micronic_plate_orig well_pos_micronic_plate)

    suspicious_columns.each do |column|
      type = Isolate.column_for_attribute(column).type

      if type == :decimal || type == :integer || type == :boolean
        sql = "SELECT \"isolates\".* FROM \"isolates\" WHERE (\"isolates\".\"#{column}\" IS NOT NULL)"
      elsif type == :string || type == :text
        sql = "SELECT \"isolates\".* FROM \"isolates\" WHERE (NOT ((\"isolates\".\"#{column}\" = '' OR \"isolates\".\"#{column}\" IS NULL)))"
      end

      isolates_size = Isolate.find_by_sql(sql).size
      puts "There are #{isolates_size} isolates where column #{column} is used."
    end
  end

  task create_aliquots: :environment do
    Isolate.all.each do |isolate|
      isolate.aliquots.create(comment: isolate.comment_orig,
                              concentration: isolate.concentration_orig,
                              lab_id: isolate.lab_id_orig,
                              micronic_plate_id: isolate.micronic_plate_id_orig,
                              micronic_tube: isolate.micronic_tube_id_orig,
                              well_pos_micronic_plate: isolate.well_pos_micronic_plate_orig,
                              is_original: true)

      # Only create copy aliquot if any actual values exist
      if isolate.comment_copy || isolate.concentration_copy || isolate.lab_id_copy || isolate.micronic_plate_id_copy ||
          isolate.micronic_tube_id_copy || isolate.well_pos_micronic_plate_copy
        isolate.aliquots.create(comment: isolate.comment_copy,
                                concentration: isolate.concentration_copy,
                                lab_id: isolate.lab_id_copy,
                                micronic_plate_id: isolate.micronic_plate_id_copy,
                                micronic_tube: isolate.micronic_tube_id_copy,
                                well_pos_micronic_plate: isolate.well_pos_micronic_plate_copy,
                                is_original: false)
      end
    end
  end

  # Draft for a migration to remove unused columns
  #  def change
  #     remove_column :isolates, :comment_copy, :text
  #     remove_column :isolates, :comment_orig, :text
  #
  #     remove_column :isolates, :concentration, :decimal
  #     remove_column :isolates, :concentration_orig, :decimal
  #     remove_column :isolates, :concentration_copy, :decimal
  #
  #     remove_column :isolates, :lab_id_orig, :integer
  #     remove_column :isolates, :lab_id_copy, :integer
  #
  #     remove_column :isolates, :micronic_plate_id, :integer
  #     remove_column :isolates, :micronic_plate_id_orig, :integer
  #     remove_column :isolates, :micronic_plate_id_copy, :integer
  #
  #     remove_column :isolates, :micronic_tube_id, :string
  #     remove_column :isolates, :micronic_tube_id_orig, :string
  #     remove_column :isolates, :micronic_tube_id_copy, :string
  #
  #     remove_column :isolates, :well_pos_micronic_plate, :string
  #     remove_column :isolates, :well_pos_micronic_plate_orig, :string
  #     remove_column :isolates, :well_pos_micronic_plate_copy, :string
  #   end
end