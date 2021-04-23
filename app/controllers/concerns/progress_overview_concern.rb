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

  def progress_table(current_project_id, marker_id)
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

    primer_read_cnts = PrimerRead.in_project(current_project_id)
                                 .joins(contig: [isolate: [individual: :taxon]])
                                 .where(contigs: {marker_id: marker_id})
                                 .order('taxa.scientific_name')
                                 .group('taxa.scientific_name')
                                 .count

    contig_cnts = Contig.in_project(current_project_id)
                        .joins(isolate: [individual: :taxon])
                        .where(marker_id: marker_id)
                        .order('taxa.scientific_name')
                        .group('taxa.scientific_name')
                        .count

    marker_sequence_cnts = MarkerSequence.in_project(current_project_id)
                                         .joins(isolate: [individual: :taxon])
                                         .where(marker: marker_id)
                                         .order('taxa.scientific_name')
                                         .group('taxa.scientific_name')
                                         .count

    taxon_ranks = Taxon.where(scientific_name: individual_cnts.keys)
                       .select(:scientific_name, :taxonomic_rank)
                       .collect { |t| [t.scientific_name, t.taxonomic_rank] }
                       .to_h

    progress_table = ''.dup
    progress_table << CSV.generate_line(%w(Taxon TaxonomicRank #Specimen #Isolates #Reads #Contigs #MarkerSequences))

    individual_cnts.each do |taxon_name, cnt|
      progress_table << CSV.generate_line([taxon_name,
              taxon_ranks[taxon_name].split('_')[1].humanize,
              cnt,
              isolate_cnts[taxon_name],
              primer_read_cnts[taxon_name],
              contig_cnts[taxon_name],
              marker_sequence_cnts[taxon_name]])
    end

    progress_table
  end
end
