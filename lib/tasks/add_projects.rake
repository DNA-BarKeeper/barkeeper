namespace :data do
  task :add_general_project => :environment do
    project = Project.find_or_create_by(name: 'All')

    values = User.all.map { |user| "(#{project.id},#{user.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO projects_users (project_id, user_id) VALUES #{values}")

    values = Issue.all.map { |issue| "(#{issue.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO issues_projects (issue_id, project_id) VALUES #{values}")

    values = Primer.all.map { |primer| "(#{primer.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO primers_projects (primer_id, project_id) VALUES #{values}")

    values = Marker.all.map { |marker| "(#{marker.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO markers_projects (marker_id, project_id) VALUES #{values}")

    values = Isolate.find_each.map { |isolate| "(#{isolate.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO isolates_projects (isolate_id, project_id) VALUES #{values}")

    values = PrimerRead.find_each.map { |read| "(#{read.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO primer_reads_projects (primer_read_id, project_id) VALUES #{values}")

    values = Contig.find_each.map { |contig| "(#{contig.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO contigs_projects (contig_id, project_id) VALUES #{values}")

    values = MarkerSequence.find_each.map { |ms| "(#{ms.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO marker_sequences_projects (marker_sequence_id, project_id) VALUES #{values}")

    values = Individual.find_each.map { |individual| "(#{individual.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO individuals_projects (individual_id, project_id) VALUES #{values}")

    values = Species.find_each.map { |species| "(#{project.id},#{species.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO projects_species (project_id, species_id) VALUES #{values}")

    values = Family.all.map { |family| "(#{family.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO families_projects (family_id, project_id) VALUES #{values}")

    values = Order.all.map { |order| "(#{order.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO orders_projects (order_id, project_id) VALUES #{values}")

    values = HigherOrderTaxon.all.map { |hot| "(#{hot.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO higher_order_taxa_projects (higher_order_taxon_id, project_id) VALUES #{values}")

    values = Lab.all.map { |lab| "(#{lab.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO labs_projects (lab_id, project_id) VALUES #{values}")

    values = Freezer.all.map { |freezer| "(#{freezer.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO freezers_projects (freezer_id, project_id) VALUES #{values}")

    values = LabRack.all.map { |lab_rack| "(#{lab_rack.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO lab_racks_projects (lab_rack_id, project_id) VALUES #{values}")

    values = MicronicPlate.all.map { |micronic_plate| "(#{micronic_plate.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO micronic_plates_projects (micronic_plate_id, project_id) VALUES #{values}")

    values = PlantPlate.all.map { |plant_plate| "(#{plant_plate.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO plant_plates_projects (plant_plate_id, project_id) VALUES #{values}")
  end

  desc 'Add GBOL5 project to all eligible records.'
  task :add_gbol5_project => :environment do
    project = Project.find_or_create_by(name: 'GBOL5')

    gbol_labs = %w(BGBM IEB NEES ZFMK Gießen)
    values = Lab.where(labcode: gbol_labs).map { |lab| "(#{lab.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO labs_projects (lab_id, project_id) VALUES #{values}")

    values = Freezer.joins(:lab).merge(Lab.in_project(project.id)).map { |freezer| "(#{freezer.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO freezers_projects (freezer_id, project_id) VALUES #{values}")

    values = LabRack.joins(:freezer).merge(Freezer.in_project(project.id)).map { |lab_rack| "(#{lab_rack.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO lab_racks_projects (lab_rack_id, project_id) VALUES #{values}")

    values = MicronicPlate.joins(:lab_rack).merge(LabRack.in_project(project.id)).map { |micronic_plate| "(#{micronic_plate.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO micronic_plates_projects (micronic_plate_id, project_id) VALUES #{values}")

    values = PlantPlate.all.map { |plant_plate| "(#{plant_plate.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO plant_plates_projects (plant_plate_id, project_id) VALUES #{values}")

    # All users who belong to a GBOL5 lab
    values = User.joins(:lab).merge(Lab.in_project(project.id)).map { |user| "(#{project.id},#{user.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO projects_users (project_id, user_id) VALUES #{values}")

    # All GBOL5 markers
    values = Marker.gbol_marker.map { |marker| "(#{marker.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO markers_projects (marker_id, project_id) VALUES #{values}")

    # All primers that belong to a GBOL5 marker
    values = Primer.joins(:marker).merge(Marker.in_project(project.id)).map { |primer| "(#{primer.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO primers_projects (primer_id, project_id) VALUES #{values}")

    # All isolates with either GBOL or DB in their name
    values = Isolate.where("lab_nr ilike ?", "gbol%").or(Isolate.where("lab_nr ilike ?", "db%")).map { |isolate| "(#{isolate.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO isolates_projects (isolate_id, project_id) VALUES #{values}")

    # All contigs with either GBOL or DB in their name
    values = Contig.where("name ilike ?", "gbol%").or(Contig.where("name ilike ?", "db%")).map { |contig| "(#{contig.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO contigs_projects (contig_id, project_id) VALUES #{values}")

    # All primer reads that belong to GBOL5 contigs
    values = PrimerRead.joins(:contig).merge(Contig.in_project(project.id)).map { |read| "(#{read.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO primer_reads_projects (primer_read_id, project_id) VALUES #{values}")

    # All issues that either belong to contigs or primer reads within the GBOL5 project
    values = Issue.joins(:contigs).merge(Contig.in_project(project.id)).or(Issue.joins(:primer_reads).merge(PrimerRead.in_project(project.id))).map { |issue| "(#{issue.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO issues_projects (issue_id, project_id) VALUES #{values}")

    # All sequences with either GBOL or DB in their name
    values = MarkerSequence.where("name ilike ?", "gbol%").or(MarkerSequence.where("name ilike ?", "db%")).map { |ms| "(#{ms.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO marker_sequences_projects (marker_sequence_id, project_id) VALUES #{values}")

    # All specimens which belong to a GBOL5 isolate
    values = Individual.joins(:isolates).merge(Isolate.in_project(project.id)).map { |individual| "(#{individual.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO individuals_projects (individual_id, project_id) VALUES #{values}")

    # All species, families, orders and taxa
    values = Species.find_each.map { |species| "(#{project.id},#{species.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO projects_species (project_id, species_id) VALUES #{values}")

    values = Family.all.map { |family| "(#{family.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO families_projects (family_id, project_id) VALUES #{values}")

    values = Order.all.map { |order| "(#{order.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO orders_projects (order_id, project_id) VALUES #{values}")

    values = HigherOrderTaxon.all.map { |hot| "(#{hot.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO higher_order_taxa_projects (higher_order_taxon_id, project_id) VALUES #{values}")
  end
end
