# frozen_string_literal: true

module ProgressOverviewConcern
  extend ActiveSupport::Concern

  def progress_tree_json(current_project_id, marker_id)
    taxa = Taxon.in_project(current_project_id).roots
                .where(taxonomic_rank: :is_unranked).first
                .subtree
                .where.not(taxonomic_rank: [:is_genus, :is_species, :is_subspecies])

    marker_seq_cnts = MarkerSequence.joins(isolate: [individual: :taxon])
                                    .where(marker: marker_id)
                                    .select("taxa.id as id, taxa.ancestry as ancestry,count(*) as count")
                                    .group('taxa.id')

    taxa_counts = Hash.new(0)
    marker_seq_cnts.map do |t|
      t.ancestry.split('/').each { |a| taxa_counts[a.to_i] += 1 if t.count.positive? }
    end

    taxa.arrange_serializable do | parent, children |
      { id: parent.id,
        scientific_name: parent.scientific_name,
        size: parent.descendants_count,
        finished_size: taxa_counts[parent.id],
        children: children
      }
    end.to_json
  end

  def progress_table(current_project_id)
    individual_cnts = Individual.in_project(current_project_id)
                                .joins(:taxon)
                                .order('taxa.scientific_name')
                                .group('taxa.scientific_name')
                                .count

    isolate_cnts = Isolate.in_project(current_project_id)
                             .joins(individual: :taxon)
                             .order('taxa.scientific_name')
                             .group('taxa.scientific_name')
                             .count

    # TODO: Loop over projects markers from here on and replace marker ID
    primer_read_cnts = PrimerRead.in_project(current_project_id)
                                 .joins(contig: [isolate: [individual: :taxon]])
                                 .where(contigs: {marker_id: 5})
                                 .order('taxa.scientific_name')
                                 .group('taxa.scientific_name')
                                 .count

    contig_cnts = Contig.in_project(current_project_id)
                        .joins(isolate: [individual: :taxon])
                        .where(marker: 5)
                        .order('taxa.scientific_name')
                        .group('taxa.scientific_name')
                        .count

    marker_sequence_cnts = MarkerSequence.in_project(current_project_id)
                                         .joins(isolate: [individual: :taxon])
                                         .where(marker: 5)
                                         .order('taxa.scientific_name')
                                         .group('taxa.scientific_name')
                                         .count

    taxon_ranks = Taxon.where(scientific_name: individual_cnts.keys)
                       .select(:scientific_name, :taxonomic_rank)
                       .collect { |t| [t.scientific_name, t.taxonomic_rank] }
                       .to_h

    CSV.open('progress_table.csv', 'w') do |csv|
      csv << %w(Taxon Rank #Specimen #Isolates #Reads #Contigs #MS)

      individual_cnts.each do |taxon_name, cnt|
        csv << [taxon_name,
                taxon_ranks[taxon_name].humanize,
                cnt,
                isolate_cnts[taxon_name],
                primer_read_cnts[taxon_name],
                contig_cnts[taxon_name],
                marker_sequence_cnts[taxon_name]]
      end
    end
  end

  def all_taxa_json(current_project_id)
    root = { :name => 'root', 'children' => [] }
    taxa = HigherOrderTaxon.in_project(current_project_id).includes(orders: [:families]).order(:position)
    species_count_per_family = Species.in_project(current_project_id).joins(:family).order('families.name').group('families.name').count

    i = 0
    taxa.each do |taxon|
      orders = taxon.orders
      children = root['children']
      children[i] = { :name => taxon.name, 'children' => [] }
      j = 0
      orders.each do |order|
        families = order.families
        children2 = children[i]['children']
        children2[j] = { :name => order.name, 'children' => [] }
        k = 0
        families.each do |family|
          children3 = children2[j]['children']
          children3[k] = { name: family.name, size: species_count_per_family[family.name].to_i }
          k += 1
        end
        j += 1
      end
      i += 1
    end

    root
  end

  def finished_taxa_json(current_project_id, marker_id)
    root = { :name => 'root', 'children' => [] }
    taxa = HigherOrderTaxon.in_project(current_project_id).includes(orders: [:families]).order(:position)
    marker_sequence_cnts = MarkerSequence.in_project(current_project_id).joins(isolate: [individual: [species: :family]]).where(marker: marker_id).order('families.name').group('families.name').count

    i = 0
    taxa.each do |taxon|
      orders = taxon.orders
      children = root['children']
      children[i] = { :name => taxon.name, 'children' => [] }
      j = 0
      orders.each do |order|
        families = order.families
        children2 = children[i]['children']
        children2[j] = { :name => order.name, 'children' => [] }
        k = 0
        families.each do |family|
          children3 = children2[j]['children']
          children3[k] = { name: family.name, size: marker_sequence_cnts[family.name].to_i }
          k += 1
        end
        j += 1
      end
      i += 1
    end

    root
  end

  # private
  #
  # def node_size(node)
  #   Taxon.descendants_of(node).where(children_count: 0).size
  # end
end
