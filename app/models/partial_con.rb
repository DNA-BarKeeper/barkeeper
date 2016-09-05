class PartialCon < ActiveRecord::Base
  belongs_to :contig, counter_cache: true
  has_many :primer_reads

  def mira_consensus_qualities

    group_probs_all_pos=[]

    # for each position:
    (0...aligned_sequence.length).each do |i|

      unless aligned_qualities[i] < 0 #cases with gap in consensus, -1 or -10

        #get group probabilities for consensus character:

        group_prob=0

        ctr=0

        primer_reads.each do |r|

          if ctr>1
            break
          end

          if r.aligned_seq[i]==aligned_sequence[i]

            group_prob += r.aligned_qualities[i]

          end

          ctr+=1

        end

        if group_prob > 93
          group_probs_all_pos << 93
        else
          group_probs_all_pos << group_prob
        end

      end

    end

    group_probs_all_pos

  end

  def test_name
    puts id
  end

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

  def to_json_for_position(position_string, width_in_bases)

    start_pos = position_string.to_i

    start_pos = 0 if start_pos < 0

    end_pos=start_pos+(width_in_bases.to_i-1)

    if end_pos > self.aligned_qualities.length
      end_pos = self.aligned_qualities.length-1;
    end

    # corresponds to which full page?:
    page = (start_pos/aligned_qualities.length).to_i

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
