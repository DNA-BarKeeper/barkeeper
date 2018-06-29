class MislabelAnalysis < ApplicationRecord
  belongs_to :marker
  has_many :mislabels, :dependent => :destroy
  has_and_belongs_to_many :marker_sequences

  def percentage_of_mislabels
    ((mislabels.size / total_seq_number.to_f) * 100).round(2) if total_seq_number&.positive?
  end

  def self.import(file, title, total_seq_number = 0, marker_id = nil, automatic = false)
    column_names = %w[SeqID MislabeledLevel OriginalLabel ProposedLabel Confidence OriginalTaxonomyPath ProposedTaxonomyPath PerRankConfidence]

    mislabel_analysis = MislabelAnalysis.create(title: title, marker_id: marker_id, automatic: automatic, total_seq_number: total_seq_number)

    # Parse file
    File.open(file, 'r').each do |row|
      next if row.starts_with?(';')

      row = Hash[[column_names, row.split("\t")].transpose]

      mislabel = Mislabel.new
      mislabel.level = row['MislabeledLevel']
      mislabel.confidence = row['Confidence'].to_f
      mislabel.proposed_label = row['ProposedLabel']
      mislabel.proposed_path = row['ProposedTaxonomyPath']
      mislabel.path_confidence = row['PerRankConfidence']
      mislabel.save

      marker_sequence = MarkerSequence.find_by_name(row['SeqID'])
      if marker_sequence.nil? && row['SeqID'].starts_with?('DB')
        marker_sequence = MarkerSequence.find_by_name(row['SeqID'].gsub('DB', 'DB '))
      end
      marker_sequence.mislabels << mislabel

      mislabel_analysis.mislabels << mislabel
      mislabel_analysis.marker_sequences << marker_sequence
    end

    # Return new analysis object
    mislabel_analysis
  end
end
