namespace :data do
  task :add_general_project => :environment do
    project = Project.new(name: 'All', description: 'Contains all records')
    project.save

    values = User.all.map { |user| "(#{project.id},#{user.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO projects_users (project_id, user_id) VALUES #{values}")

    values = Issue.all.map { |issue| "(#{issue.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO issues_projects (issue_id, project_id) VALUES #{values}")

    values = Primer.all.map { |primer| "(#{primer.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO primers_projects (primer_id, project_id) VALUES #{values}")

    values = Marker.all.map { |marker| "(#{marker.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO markers_projects (marker_id, project_id) VALUES #{values}")

    values = Isolate.all.map { |isolate| "(#{isolate.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO isolates_projects (isolate_id, project_id) VALUES #{values}")

    values = PrimerRead.all.map { |read| "(#{read.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO primer_reads_projects (primer_read_id, project_id) VALUES #{values}")

    values = Contig.all.map { |contig| "(#{contig.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO contigs_projects (contig_id, project_id) VALUES #{values}")

    values = MarkerSequence.all.map { |ms| "(#{ms.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO marker_sequences_projects (marker_sequence_id, project_id) VALUES #{values}")

    values = Individual.all.map { |individual| "(#{individual.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO individuals_projects (individual_id, project_id) VALUES #{values}")

    values = Species.all.map { |species| "(#{project.id},#{species.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO projects_species (project_id, species_id) VALUES #{values}")

    values = Family.all.map { |family| "(#{family.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO families_projects (family_id, project_id) VALUES #{values}")

    values = Order.all.map { |order| "(#{order.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO orders_projects (order_id, project_id) VALUES #{values}")

    values = HigherOrderTaxon.all.map { |hot| "(#{hot.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO higher_order_taxa_projects (higher_order_taxon_id, project_id) VALUES #{values}")

    values = Lab.all.map { |lab| "(#{lab.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO labs_projects (lab_id, project_id) VALUES #{values}")
  end


  task :add_gbol5_project => :environment do
    project = Project.new(name: 'All', description: 'Contains all records')
    project.save

    values = User.all.map { |user| "(#{project.id},#{user.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO projects_users (project_id, user_id) VALUES #{values}")

    values = Issue.all.map { |issue| "(#{issue.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO issues_projects (issue_id, project_id) VALUES #{values}")

    values = Primer.all.map { |primer| "(#{primer.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO primers_projects (primer_id, project_id) VALUES #{values}")

    values = Marker.all.map { |marker| "(#{marker.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO markers_projects (marker_id, project_id) VALUES #{values}")

    values = Isolate.all.map { |isolate| "(#{isolate.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO isolates_projects (isolate_id, project_id) VALUES #{values}")

    values = PrimerRead.all.map { |read| "(#{read.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO primer_reads_projects (primer_read_id, project_id) VALUES #{values}")

    values = Contig.all.map { |contig| "(#{contig.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO contigs_projects (contig_id, project_id) VALUES #{values}")

    values = MarkerSequence.all.map { |ms| "(#{ms.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO marker_sequences_projects (marker_sequence_id, project_id) VALUES #{values}")

    values = Individual.all.map { |individual| "(#{individual.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO individuals_projects (individual_id, project_id) VALUES #{values}")

    values = Species.all.map { |species| "(#{project.id},#{species.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO projects_species (project_id, species_id) VALUES #{values}")

    values = Family.all.map { |family| "(#{family.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO families_projects (family_id, project_id) VALUES #{values}")

    values = Order.all.map { |order| "(#{order.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO orders_projects (order_id, project_id) VALUES #{values}")

    values = HigherOrderTaxon.all.map { |hot| "(#{hot.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO higher_order_taxa_projects (higher_order_taxon_id, project_id) VALUES #{values}")

    values = Lab.all.map { |lab| "(#{lab.id},#{project.id})" }.join(',')
    ActiveRecord::Base.connection.execute("INSERT INTO labs_projects (lab_id, project_id) VALUES #{values}")
  end
end
