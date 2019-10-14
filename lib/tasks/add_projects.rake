# frozen_string_literal: true

namespace :data do
  desc 'Add general project to all records.'
  task add_general_project: :environment do
    project = Project.find_or_create_by(name: 'All Records')

    add_to_join_table(project, Individual.all.select(:id).find_each)
    add_to_join_table(project, Species.all.select(:id).find_each)
    add_to_join_table(project, Family.all.select(:id))
    add_to_join_table(project, Order.all.select(:id))
    add_to_join_table(project, HigherOrderTaxon.all.select(:id))

    add_to_join_table(project, Lab.all.select(:id))
    add_to_join_table(project, Freezer..all.select(:id))
    add_to_join_table(project, Shelf.all.select(:id))
    add_to_join_table(project, LabRack..all.select(:id))
    add_to_join_table(project, MicronicPlate..all.select(:id))
    add_to_join_table(project, PlantPlate.all.select(:id))
    add_to_join_table(project, User.all.select(:id))
    add_to_join_table(project, Marker.all.select(:id))
    add_to_join_table(project, Primer.all.select(:id))
    add_to_join_table(project, Isolate..all.select(:id).find_each)
    add_to_join_table(project, Contig..all.select(:id).find_each)
    add_to_join_table(project, PrimerRead.all.select(:id).find_each)
    add_to_join_table(project, Issue.all.select(:id))
    add_to_join_table(project, MarkerSequence.all.select(:id))
  end

  desc 'Add GBOL5 project to all eligible records.'
  task add_gbol5_project: :environment do
    project = Project.find_or_create_by(name: 'GBOL5')
    gbol_labs = %w[BGBM IEB NEES ZFMK Gießen]

    Shelf.update_all(freezer_id: Freezer.first.id)

    # Order of method calls is important here!
    add_to_join_table(project, Lab.where(labcode: gbol_labs).select(:id))
    add_to_join_table(project, Freezer.joins(:lab).merge(Lab.in_project(project.id)).select(:id))
    add_to_join_table(project, Shelf.joins(:freezer).merge(Freezer.in_project(project.id)).select(:id))
    add_to_join_table(project, LabRack.joins(:freezer).merge(Freezer.in_project(project.id)).select(:id))
    add_to_join_table(project, MicronicPlate.joins(:lab_rack).merge(LabRack.in_project(project.id)).select(:id))
    add_to_join_table(project, PlantPlate.all.select(:id))
    add_to_join_table(project, User.joins(:lab).merge(Lab.in_project(project.id)).select(:id))
    # add_to_join_table(project, Marker.where(is_gbol: true).select(:id)) # Column is_gbol does not exist anymore
    add_to_join_table(project, Primer.joins(:marker).merge(Marker.in_project(project.id)).select(:id))
    add_to_join_table(project, Isolate.where('lab_isolation_nr ilike ?', 'gbol%').or(Isolate.where('lab_isolation_nr ilike ?', 'db%')).select(:id).find_each)
    add_to_join_table(project, Contig.where('name ilike ?', 'gbol%').or(Contig.where('name ilike ?', 'db%')).select(:id).find_each)
    add_to_join_table(project, PrimerRead.joins(:contig).merge(Contig.in_project(project.id).select(:id)).select(:id).find_each)
    add_to_join_table(project, Issue.joins(:primer_read).merge(PrimerRead.in_project(project.id)).select(:id) + Issue.joins(:contig).merge(Contig.in_project(project.id)).select(:id))
    add_to_join_table(project, MarkerSequence.where('name ilike ?', 'gbol%').or(MarkerSequence.where('name ilike ?', 'db%')).select(:id))

    add_to_join_table(project, Individual.joins(:isolates).merge(Isolate.in_project(project.id)).select(:id).find_each)
    add_to_join_table(project, Species.all.select(:id).find_each)
    add_to_join_table(project, Family.all.select(:id))
    add_to_join_table(project, Order.all.select(:id))
    add_to_join_table(project, HigherOrderTaxon.all.select(:id))
  end

  desc 'Add transects project to all eligible records.'
  task add_transects_project: :environment do
    project = Project.find_or_create_by(name: '3transects')
    users = ['Kai Müller', 'Dietmar Quandt', 'Sarah Wiechers']

    add_to_join_table(project, Individual.all.select(:id).find_each)
    add_to_join_table(project, Species.all.select(:id).find_each)
    add_to_join_table(project, Family.all.select(:id))
    add_to_join_table(project, Order.all.select(:id))
    add_to_join_table(project, HigherOrderTaxon.all.select(:id))

    # Order of method calls is important here!
    add_to_join_table(project, Lab.all.select(:id))
    add_to_join_table(project, User.where(name: users).select(:id))
    add_to_join_table(project, Freezer.all.select(:id))
    add_to_join_table(project, Shelf.joins(:freezer).merge(Freezer.in_project(project.id)).select(:id))
    add_to_join_table(project, LabRack.joins(:freezer).merge(Freezer.in_project(project.id)).select(:id))
    add_to_join_table(project, MicronicPlate.joins(:lab_rack).merge(LabRack.in_project(project.id)).select(:id))
    add_to_join_table(project, PlantPlate.all.select(:id))
    add_to_join_table(project, Marker.all.select(:id))
    add_to_join_table(project, Primer.joins(:marker).merge(Marker.in_project(project.id)).select(:id))
    add_to_join_table(project, Isolate.where('lab_isolation_nr like ?', 'F%').or(Isolate.where('lab_isolation_nr like ?', 'B%')).select(:id).find_each)
    add_to_join_table(project, Contig.where('name like ?', 'F%').or(Contig.where('name like ?', 'B%')).select(:id).find_each)
    add_to_join_table(project, PrimerRead.joins(:contig).merge(Contig.in_project(project.id).select(:id)).select(:id).find_each)
    add_to_join_table(project, Issue.joins(:primer_read).merge(PrimerRead.in_project(project.id)).select(:id) + Issue.joins(:contig).merge(Contig.in_project(project.id)).select(:id))
    add_to_join_table(project, MarkerSequence.where('name like ?', 'F%').or(MarkerSequence.where('name like ?', 'B%')).select(:id))
  end

  desc 'Move all individuals and related records within GBOL5 project to GBOL5_Non_German project if the country field is not "Germany" or empty.'
  task move_non_german_entries: :environment do
    non_german_project = Project.find_or_create_by(name: 'GBOL5_Non_German')
    gbol5_project = Project.find_or_create_by(name: 'GBOL5')

    individuals = Individual.in_project(gbol5_project.id).where.not(country: [nil, '', 'Germany']).includes(isolates: [contigs: [:primer_reads, :marker_sequence]])

    # Remove GBOL5 project and add GBOL5_Non_German project
    individuals.each do |individual|
      individual.projects.delete(gbol5_project)
      individual.projects << non_german_project

      individual.isolates.each do |isolate|
        isolate.projects.delete(gbol5_project)
        isolate.projects << non_german_project

        isolate.contigs.each do |contig|
          contig.projects.delete(gbol5_project)
          contig.projects << non_german_project

          contig.marker_sequence.projects.delete(gbol5_project) if contig.marker_sequence
          contig.marker_sequence.projects << non_german_project if contig.marker_sequence

          contig.issues.each do |issue|
            issue.projects.delete(gbol5_project)
            issue.projects << non_german_project
          end

          contig.primer_reads.each do |pr|
            pr.projects.delete(gbol5_project)
            pr.projects << non_german_project

            pr.issues.each do |issue|
              issue.projects.delete(gbol5_project)
              issue.projects << non_german_project
            end
          end
        end
      end
    end
  end

  desc 'Move all isolates and related records within GBOL5 project to High_Isolation_Numbers project if the GBOL number is over 1000000.'
  task move_high_isolation_numbers: :environment do
    high_numbers_project = Project.find_or_create_by(name: 'High_Isolation_Numbers')
    gbol5_project = Project.find_or_create_by(name: 'GBOL5')

    # Isolates with unreasonably high GBOL numbers
    high_numbers_pattern = /[Gg][Bb][Oo][Ll]1000\d{3}/
    gbol_numbers = Isolate.all.select(:lab_isolation_nr).map(&:lab_isolation_nr).select { |nr| nr.match(high_numbers_pattern) }
    isolates = Isolate.where(lab_isolation_nr: gbol_numbers).includes(contigs: [:primer_reads, :marker_sequence])

    # Isolates with same DB numbers as those above
    dna_bank_numbers = isolates.select(:dna_bank_id).map(&:dna_bank_id)
    dna_bank_numbers.delete('')
    isolates += Isolate.where(lab_isolation_nr: dna_bank_numbers).includes(contigs: [:primer_reads, :marker_sequence])

    puts "Moving #{isolates.size} isolates..."

    # Remove GBOL5 project and add High_Isolation_Numbers project
    isolates.each do |isolate|
      isolate.projects.delete(gbol5_project)
      isolate.add_project_and_save(high_numbers_project.id)

      isolate.contigs.each do |contig|
        contig.projects.delete(gbol5_project)
        contig.add_project_and_save(high_numbers_project.id)

        contig.marker_sequence.projects.delete(gbol5_project) if contig.marker_sequence
        contig.marker_sequence.add_project_and_save(high_numbers_project.id) if contig.marker_sequence

        contig.issues.each do |issue|
          issue.projects.delete(gbol5_project)
          issue.add_project_and_save(high_numbers_project.id)
        end

        contig.primer_reads.each do |pr|
          pr.projects.delete(gbol5_project)
          pr.add_project_and_save(high_numbers_project.id)

          pr.issues.each do |issue|
            issue.projects.delete(gbol5_project)
            issue.add_project_and_save(high_numbers_project.id)
          end
        end
      end
    end
  end

  private

  def add_to_join_table(project, records)
    record_class = records.first.class

    if record_class.name.casecmp(Project.name) == -1 # Record name comes first alphabetically
      table_name = pluralized_name(record_class) + '_' + pluralized_name(Project)
      values = records.map { |record| "(#{record.id},#{project.id})" }.join(',')
      ActiveRecord::Base.connection.execute("INSERT INTO #{table_name} (#{id_string(record_class)}, #{id_string(Project)}) VALUES #{values}") unless values.blank?
    else
      table_name = pluralized_name(Project) + '_' + pluralized_name(record_class)
      values = records.map { |record| "(#{project.id},#{record.id})" }.join(',')
      ActiveRecord::Base.connection.execute("INSERT INTO #{table_name} (#{id_string(Project)}, #{id_string(record_class)}) VALUES #{values}") unless values.blank?
    end
  end

  def id_string(record)
    record.name.underscore + '_id'
  end

  def pluralized_name(record)
    record.name.underscore.pluralize
  end
end
