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
        sql = "SELECT \"isolates\".* FROM \"isolates\" WHERE (NOT ((\"isolates\".\"comment_copy\" = '' OR \"isolates\".\"comment_copy\" IS NULL)))"
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
end