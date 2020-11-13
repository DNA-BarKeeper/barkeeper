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
namespace :export do
  desc "Writes parts of DB content into seeds.rb to seed database for course students."
  task :generate_seeds => :environment do
    markers = Marker.all
    contigs = Contig.last(2000)
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
    seeds_commands(markers, output)
    seeds_commands(contigs, output)
    output << "Contig.update_all(verified_by: user.id, verified_at: Time.now)\n"
    seeds_commands(ms, output)
    seeds_commands_isolates(isolates, output)
    seeds_commands_specimen(specimen, output) #CAUTION: Comment out autoassign in isolate.rb before running db:seed!
    seeds_commands(species, output)
    seeds_commands(families, output)
    seeds_commands(orders, output)
    seeds_commands(hots, output)

    output.close
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

  def seeds_commands_isolates(records, output_file)
    records.each do |record|
      output_file << "#{record.class.name}.create("
      output_file << "#{record.serializable_hash.delete_if {|key, value| ['created_at','updated_at', 'concentration_orig', 'concentration_copy', 'isolation_date'].include?(key)}.to_s.gsub(/[{}]/,'')}"
      if record.isolation_date
        output_file << ", \"isolation_date\"=>\"#{Date.parse(record.isolation_date.to_s).to_s}\", "
        output_file << "\"concentration_orig\"=>#{record.concentration_orig.to_f}, \"concentration_copy\"=>#{record.concentration_copy.to_f})\n"
      else
        output_file << ", \"concentration_orig\"=>\"\", \"concentration_copy\"=>\"\", \"isolation_date\"=>\"\")\n"
      end
    end
  end
end