class PartialCon < ActiveRecord::Base
  belongs_to :contig, counter_cache: true
  has_many :primer_reads

  def as_json(options={})
    super(:include => [:primer_reads])
  end

  def to_json_for_page(page, width_in_bases)

    # 0..width-in-bases slice

    # cons
    # aligned qual

    # for each read:

    # aligned seq
    # aligned qual

    if page.to_i < 0
      page = 0
    end

    start_pos=page.to_i*width_in_bases.to_i

    #test if outside range of existing sites; if so, use last page:

    if start_pos > self.aligned_qualities.length

      page = (aligned_qualities.length/width_in_bases.to_i)
      start_pos = page.to_i*width_in_bases.to_i

    end

    end_pos=start_pos+(width_in_bases.to_i-1)

    if end_pos > self.aligned_qualities.length
      end_pos = self.aligned_qualities.length-1;
    end

    {
        :page => page.as_json,
        :aligned_sequence => self.aligned_sequence[start_pos..end_pos].as_json,
        :aligned_qualities => self.aligned_qualities[start_pos..end_pos].as_json,
        :start_pos => start_pos.as_json,
        :end_pos => end_pos.as_json,
        :primer_reads => self.primer_reads.map { |pr| pr.slice_to_json(start_pos, end_pos) }
    }

  end

end
