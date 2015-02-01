class PartialCon < ActiveRecord::Base
  belongs_to :contig
  has_many :primer_reads


  def as_json(options={})
    super(:include => [:primer_reads])
  end

end
