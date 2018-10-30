# frozen_string_literal: true

class MislabelAnalysis < ApplicationRecord
  belongs_to :marker
  has_many :mislabels, dependent: :destroy
  has_and_belongs_to_many :marker_sequences

  def percentage_of_mislabels
    ((mislabels.size / total_seq_number.to_f) * 100).round(2) if total_seq_number&.positive?
  end

  # Import SATIVA result table (*.mis)
  def self.import(file, title, total_seq_number = 0, marker_id = nil, automatic = false)
    column_names = %w[SeqID MislabeledLevel OriginalLabel ProposedLabel
                      Confidence OriginalTaxonomyPath ProposedTaxonomyPath
                      PerRankConfidence]

    mislabel_analysis = MislabelAnalysis.create(title: title, marker_id: marker_id, automatic: automatic, total_seq_number: total_seq_number)

    File.open(file, 'r').each do |row|
      next if row.start_with?(';')

      row = Hash[[column_names, row.split("\t")].transpose]

      mislabel = Mislabel.new
      mislabel.level = row['MislabeledLevel']
      mislabel.confidence = row['Confidence'].to_f
      mislabel.proposed_label = row['ProposedLabel']
      mislabel.proposed_path = row['ProposedTaxonomyPath']
      mislabel.path_confidence = row['PerRankConfidence']
      mislabel.save

      name = row['SeqID'].split('_')[0..1].join('_')
      marker_sequence = MarkerSequence.find_by_name(name)
      if marker_sequence.nil? && name.start_with?('DB')
        marker_sequence = MarkerSequence.find_by_name(name.gsub('DB', 'DB '))
      end

      next unless marker_sequence

      marker_sequence.mislabels << mislabel

      mislabel_analysis.mislabels << mislabel
      mislabel_analysis.marker_sequences << marker_sequence
    end

    mislabel_analysis
  end
end
