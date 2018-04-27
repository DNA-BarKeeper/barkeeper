namespace :data do
  desc 'Add general project to all records.'
  task :add_general_project => :environment do
    project = Project.find_or_create_by(name: 'All')

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
  task :add_gbol5_project => :environment do
    project = Project.find_or_create_by(name: 'GBOL5')
    gbol_labs = %w(BGBM IEB NEES ZFMK Gießen)

    Shelf.update_all(freezer_id: Freezer.first.id)

    # Order of method calls is important here!
    add_to_join_table(project, Lab.where(labcode: gbol_labs).select(:id))
    add_to_join_table(project, Freezer.joins(:lab).merge(Lab.in_project(project.id)).select(:id))
    add_to_join_table(project, Shelf.joins(:freezer).merge(Freezer.in_project(project.id)).select(:id))
    add_to_join_table(project, LabRack.joins(:freezer).merge(Freezer.in_project(project.id)).select(:id))
    add_to_join_table(project, MicronicPlate.joins(:lab_rack).merge(LabRack.in_project(project.id)).select(:id))
    add_to_join_table(project, PlantPlate.all.select(:id))
    add_to_join_table(project, User.joins(:lab).merge(Lab.in_project(project.id)).select(:id))
    add_to_join_table(project, Marker.where(is_gbol: true).select(:id))
    add_to_join_table(project, Primer.joins(:marker).merge(Marker.in_project(project.id)).select(:id))
    add_to_join_table(project, Isolate.where("lab_nr ilike ?", "gbol%").or(Isolate.where("lab_nr ilike ?", "db%")).select(:id).find_each)
    add_to_join_table(project, Contig.where("name ilike ?", "gbol%").or(Contig.where("name ilike ?", "db%")).select(:id).find_each)
    add_to_join_table(project, PrimerRead.joins(:contig).merge(Contig.in_project(project.id).select(:id)).select(:id).find_each)
    add_to_join_table(project, Issue.joins(:primer_read).merge(PrimerRead.in_project(project.id)).select(:id) + Issue.joins(:contig).merge(Contig.in_project(project.id)).select(:id))
    add_to_join_table(project, MarkerSequence.where("name ilike ?", "gbol%").or(MarkerSequence.where("name ilike ?", "db%")).select(:id))

    add_to_join_table(project, Individual.joins(:isolates).merge(Isolate.in_project(project.id)).select(:id).find_each)
    add_to_join_table(project, Species.all.select(:id).find_each)
    add_to_join_table(project, Family.all.select(:id))
    add_to_join_table(project, Order.all.select(:id))
    add_to_join_table(project, HigherOrderTaxon.all.select(:id))
  end

  desc 'Add transects project to all eligible records.'
  task :add_transects_project => :environment do
    project = Project.find_or_create_by(name: '3transects')

    # Order of method calls is important here!
    # add_to_join_table(project, Lab.where(labcode: gbol_labs).select(:id))
    # add_to_join_table(project, Freezer.joins(:lab).merge(Lab.in_project(project.id)).select(:id))
    # add_to_join_table(project, Shelf.joins(:freezer).merge(Freezer.in_project(project.id)).select(:id))
    # add_to_join_table(project, LabRack.joins(:freezer).merge(Freezer.in_project(project.id)).select(:id))
    # add_to_join_table(project, MicronicPlate.joins(:lab_rack).merge(LabRack.in_project(project.id)).select(:id))
    # add_to_join_table(project, PlantPlate.all.select(:id))
    # add_to_join_table(project, User.joins(:lab).merge(Lab.in_project(project.id)).select(:id))
    # add_to_join_table(project, Marker.where(is_gbol: true).select(:id))
    # add_to_join_table(project, Primer.joins(:marker).merge(Marker.in_project(project.id)).select(:id))
    # add_to_join_table(project, Isolate.where("lab_nr ilike ?", "gbol%").or(Isolate.where("lab_nr ilike ?", "db%")).select(:id).find_each)
    # add_to_join_table(project, Contig.where("name ilike ?", "gbol%").or(Contig.where("name ilike ?", "db%")).select(:id).find_each)
    # add_to_join_table(project, PrimerRead.joins(:contig).merge(Contig.in_project(project.id).select(:id)).select(:id).find_each)
    # add_to_join_table(project, Issue.joins(:primer_read).merge(PrimerRead.in_project(project.id)).select(:id) + Issue.joins(:contig).merge(Contig.in_project(project.id)).select(:id))
    # add_to_join_table(project, MarkerSequence.where("name ilike ?", "gbol%").or(MarkerSequence.where("name ilike ?", "db%")).select(:id))
    #
    # add_to_join_table(project, Individual.joins(:isolates).merge(Isolate.in_project(project.id)).select(:id).find_each)
    # add_to_join_table(project, Species.all.select(:id).find_each)
    # add_to_join_table(project, Family.all.select(:id))
    # add_to_join_table(project, Order.all.select(:id))
    # add_to_join_table(project, HigherOrderTaxon.all.select(:id))
  end

  private

  def add_to_join_table(project, records)
    record_class = records.first.class

    if record_class.name.casecmp(Project.name) == -1 # Record name comes first alphabetically
      table_name = pluralized_name(record_class) + '_' + pluralized_name(Project)
      values = records.map { |record| "(#{record.id},#{project.id})" }.join(',')
      ActiveRecord::Base.connection.execute("INSERT INTO #{table_name} (#{id_string(record_class)}, #{id_string(Project)}) VALUES #{values}")
    else
      table_name = pluralized_name(Project) + '_' + pluralized_name(record_class)
      values = records.map { |record| "(#{project.id},#{record.id})" }.join(',')
      ActiveRecord::Base.connection.execute("INSERT INTO #{table_name} (#{id_string(Project)}, #{id_string(record_class)}) VALUES #{values}")
    end
  end

  def id_string(record)
    record.name.downcase + '_id'
  end

  def pluralized_name(record)
    record.name.downcase.pluralize
  end
end
