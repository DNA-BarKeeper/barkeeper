class MarkerSequenceSearch < ApplicationRecord
  belongs_to :user

  def marker_sequences
    marker_sequences ||= find_marker_sequences
  end

  def as_fasta
    fasta = ""

    marker_sequences.each do |marker_sequence|
      sequence = Bio::Sequence::NA.new(marker_sequence.sequence)
      name = "#{marker_sequence.name}|#{marker_sequence.isolate.lab_nr}|#{marker_sequence.isolate.individual.specimen_id}|#{marker_sequence.isolate.individual.species.composed_name}|#{marker_sequence.isolate.individual.species.family.name}"
      fasta += sequence.to_fasta(name, 80)
    end

    fasta
  end

  private
  def find_marker_sequences
    marker_sequences = MarkerSequence.order(:name)
    marker_sequences = marker_sequences.where("marker_sequences.name ilike ?", "%#{name}%") if name.present?

    if verified != 'both'
      marker_sequences = marker_sequences.joins(:contigs).where("contigs.verified = ?", true) if (verified == 'verified')
      marker_sequences = marker_sequences.joins(:contigs).where("contigs.verified = ?", false) if (verified == 'unverified')
    end

    marker_sequences = marker_sequences.joins(:marker).where("markers.name ilike ?", "%#{marker}%") if marker.present?

    marker_sequences = marker_sequences.joins(isolate: { individual: {species: {family: :order}}}).where("orders.name ilike ?", "%#{order}%") if order.present?

    marker_sequences = marker_sequences.joins(isolate: { individual: {species: :family}}).where("families.name ilike ?", "%#{family}%") if family.present?

    marker_sequences = marker_sequences.joins(isolate: { individual: :species }).where("species.composed_name ilike ?", "%#{species}%") if species.present?

    marker_sequences = marker_sequences.joins(isolate: :individual).where("individuals.specimen_id ilike ?", "%#{specimen}%") if specimen.present?

    marker_sequences = marker_sequences.where("length(marker_sequences.sequence) >= ?", min_length) if min_length.present?
    marker_sequences = marker_sequences.where("length(marker_sequences.sequence) <= ?", max_length) if max_length.present?

    marker_sequences
  end
end
