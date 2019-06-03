namespace :export do
  desc "Writes parts of DB content into seeds.rb."
  task :generate_seeds => :environment do
    markers = Marker.all
    contigs = Contig.last(500)
    ms = MarkerSequence.where(id: contigs.map(&:marker_sequence_id))
    isolates = Isolate.where(id: contigs.map(&:isolate_id))
    specimen = Individual.where(id: isolates.map(&:individual_id))
    species = Species.where(id: specimen.map(&:species_id))
    families = Family.where(id: species.map(&:family_id))
    orders = Order.where(id: families.map(&:order_id))
    hots = HigherOrderTaxon.where(id: orders.map(&:higher_order_taxon_id))

    output = File.open("seeds.rb", 'w')

    # Create some initial data
    output << "project = Project.create!(name: 'All')\n"
    output << "user = CreateAdminService.new.call([project])\n"
    seeds_commands(contigs, output)
    output << "Contig.update_all(verified_by: user.id, verified_at: Time.now)\n"
    seeds_commands(ms, output)
    seeds_commands(isolates, output)
    seeds_commands_specimen(specimen, output)
    seeds_commands(species, output)
    seeds_commands(families, output)
    seeds_commands(orders, output)
    seeds_commands(hots, output)

    output.close
  end

  task :generate_seeds_json => :environment do
    markers = Marker.all
    contigs = Contig.last(500)
    ms = MarkerSequence.where(id: contigs.map(&:marker_sequence_id))
    isolates = Isolate.where(id: contigs.map(&:isolate_id))
    specimen = Individual.where(id: isolates.map(&:individual_id))
    species = Species.where(id: specimen.map(&:species_id))
    families = Family.where(id: species.map(&:family_id))
    orders = Order.where(id: families.map(&:order_id))
    hots = HigherOrderTaxon.where(id: orders.map(&:higher_order_taxon_id))

    output = File.open("seeds.json", 'w')

    # Create some initial data
    output << "["
    output << "{\"Marker\": #{seeds_json(markers, output)}}"
    output << "{\"Contig\": #{seeds_json(contigs, output)}}"
    output << "]"

    output.close
  end

  def seeds_json(records, output_file)
    records.each do |record|
      output_file << record.to_json
    end
  end

  def seeds_commands(records, output_file)
    records.each do |record|
      output_file << "#{record.class.name}.create(#{record.serializable_hash.delete_if {|key, value| ['created_at','updated_at', 'verified_at'].include?(key)}.to_s.gsub(/[{}]/,'')})\n"
    end
  end

  def seeds_commands_specimen(records, output_file)
    records.each do |record|
      output_file << "#{record.class.name}.create("
      output_file << "#{record.serializable_hash.delete_if {|key, value| ['created_at','updated_at', 'verified_at', 'latitude', 'longitude'].include?(key)}.to_s.gsub(/[{}]/,'')}"
      output_file << ", \"latitude\"=>#{record.latitude.to_f}, \"longitude\"=>#{record.longitude.to_f})\n"
    end
  end
end