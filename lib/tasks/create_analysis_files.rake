# frozen_string_literal: true

namespace :data do
  desc 'Create fasta and taxon file from marker sequence search for further analyses.'
  task :create_analysis_files, [:title] => [:environment] do |_, args|
    title = args[:title]

    title_split = title.split('_')
    taxon = title_split[0]
    marker = title_split[1]

    search = create_ms_search(taxon, marker)

    sequences = "#{Rails.root}/#{title}.fasta"
    tax_file = "#{Rails.root}/#{title}.tax"

    File.open(sequences, 'w+') do |f|
      f.write(search.analysis_fasta(false))
    end

    File.open(tax_file, 'w+') do |f|
      f.write(search.taxon_file(false))
    end
  end

  task :intraspecific_variation, [:taxon] => [:environment] do |_, args|
    taxon = args[:taxon]
    Marker.gbol_marker.each do |marker|
      search = create_ms_search(taxon, marker.name)

      sequences = search.marker_sequences

      # Remove singletons
      cnt = sequences.joins(isolate: [individual: :species]).distinct.reorder('species.species_component').group('species.species_component').count
      sequences = sequences.where(species: { species_component: cnt.select { |_, v| v > 1 }.keys })

      File.open("Intraspecific_variation_#{taxon}_#{marker.name}.fasta", 'w') do |file|
        file.puts MarkerSequenceSearch.fasta(sequences, { metadata: true, warnings: true }) # Label sequences with SATIVA warnings
      end
    end
  end

  def create_ms_search(taxon, marker)
    length_minima = {
      'ITS' => 485,
      'rpl16' => 580,
      'trnLF' => 516,
      'trnK-matK' => 1188
    }
    search = MarkerSequenceSearch.create(has_species: true, has_warnings: 'both', marker: marker, min_length: length_minima[marker], project_id: 5)
    search.update(higher_order_taxon: taxon) if HigherOrderTaxon.find_by_name(taxon)
    search.update(order: taxon) if Order.find_by_name(taxon)
    search.update(family: taxon) if Family.find_by_name(taxon)

    search
  end
end
