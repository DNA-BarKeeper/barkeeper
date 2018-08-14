namespace :data do
  desc 'Create fasta and taxon file from marker sequence search for further analyses.'
  task :create_analysis_files, [:title] => [:environment] do |_, args|
    length_minima = {
        'ITS' => 485,
        'rpl16' => 580,
        'trnLF' => 516,
        'trnK-matK' => 1188
    }

    title = args[:title].split('_')

    taxon = title[0]
    marker = title[1]

    search = MarkerSequenceSearch.create(has_species: true, has_warnings: 'both', marker: marker, min_length: length_minima[marker], project_id: 5)
    search.update(higher_order_taxon: taxon) if HigherOrderTaxon.find_by_name(taxon)
    search.update(order: taxon) if Order.find_by_name(taxon)
    search.update(family: taxon) if Family.find_by_name(taxon)

    sequences = "#{Rails.root}/#{title}.fasta"
    tax_file = "#{Rails.root}/#{title}.tax"

    File.open(sequences, 'w+') do |f|
      f.write(search.as_fasta)
    end

    File.open(tax_file, 'w+') do |f|
      f.write(search.taxon_file)
    end
  end
end