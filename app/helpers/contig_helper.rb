module ContigHelper
  def aligned_sequence_length(partial_con)
    partial_con.aligned_sequence.nil? ? 0 : partial_con.aligned_sequence.length
  end
end