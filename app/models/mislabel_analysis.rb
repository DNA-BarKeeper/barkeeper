class MislabelAnalysis < ApplicationRecord
  has_many :mislabels, :dependent => :destroy
  has_and_belongs_to_many :marker_sequences

  def percentage_of_mislabels
    ((mislabels.size / marker_sequences.size) * 100).round(2)
  end

  def self.import(file)
    title = File.basename(file.original_filename, ".mis")
    file = File.new(file.path)

    column_names = %w[SeqID MislabeledLevel OriginalLabel ProposedLabel Confidence OriginalTaxonomyPath ProposedTaxonomyPath PerRankConfidence]

    mislabel_analysis = MislabelAnalysis.create(title: title)

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
