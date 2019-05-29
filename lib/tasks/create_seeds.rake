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

    output = File.open("seeds.json", 'w')

    # Create some initial data
    output << "["
    output << "{\"Marker\": #{seeds_commands(markers, output)}}"
    output << "{\"Contig\": #{seeds_commands(contigs, output)}}"
    # seeds_commands(contigs, output)
    # seeds_commands(ms, output)
    # seeds_commands(isolates, output)
    # seeds_commands(specimen, output)
    # seeds_commands(species, output)
    # seeds_commands(families, output)
    # seeds_commands(orders, output)
    # seeds_commands(hots, output)
    output << "]"

    output.close
  end

  def seeds_commands(records, output_file)
    records.each do |record|
      output_file << record.to_json
      # output_file << "#{record.class.name}.create(#{record.serializable_hash.delete_if {|key, value| ['created_at','updated_at', 'verified_at'].include?(key)}.to_s.gsub(/[{}]/,'')})\n"
    end
  end
end