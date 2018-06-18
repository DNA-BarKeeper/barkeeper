module MislabelAnalysisHelper
  def percentage_mislabels(mislabel_analysis)
    "#{mislabel_analysis.mislabels.size} / #{mislabel_analysis.marker_sequences.size} (#{mislabel_analysis.percentage_of_mislabels}%)"
  end
end