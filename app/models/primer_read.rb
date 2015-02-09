class PrimerRead < ActiveRecord::Base
  belongs_to :contig
  belongs_to :partial_con
  belongs_to :primer
  has_many :issues
  has_attached_file :chromatogram,
                    :storage => :s3,
                    :s3_credentials => Proc.new{ |a| a.instance.s3_credentials },
                    :default_url => "/chromatograms/primer_read.scf"

  #do_not_validate_attachment_file_type :chromatogram

  # Validate content type
  validates_attachment_content_type :chromatogram, :content_type => /\Aapplication\/octet-stream/

  # Validate filename
  validates_attachment_file_name :chromatogram, :matches => [/scf\Z/, /ab1\Z/]


  before_create :default_name

  scope :trimmed, -> { where.not(:trimmedReadStart => nil)}
  scope :use_for_assembly, ->  { trimmed.where(:used_for_con => true)}

  validates_attachment_presence :chromatogram

  # reactivate this only after absolute-primer-position-mess (strandedness etc) clarified:
  # def expected_read_start
  #   if self.reverse
  #     if self.trimmedReadEnd and self.trimmedReadStart
  #       readable_read_length = self.trimmedReadEnd - self.trimmedReadStart
  #       self.primer.position-readable_read_length
  #     end
  #   else
  #     self.primer.position
  #   end
  # end

  def self.in_higher_order_taxon(higher_order_taxon_id)
    count=0

    HigherOrderTaxon.find(higher_order_taxon_id).orders.each do |ord|
      ord.families.each do |fam|
        fam.species.each do  |sp|
          sp.individuals.each do |ind|
            ind.isolates.each do |iso|
              iso.contigs.each do |con|
                count += con.primer_reads.count
              end
            end
          end
        end
      end
    end

    count
  end

  def contig_name
    contig.try(:name)
  end

  def contig_name=(name)
    if name == ''
      self.contig = nil
    else
      self.contig = Contig.find_or_create_by(:name => name) if name.present?
    end
  end

  def seq_for_display
    "#{self.sequence[0..30]...self.sequence[-30..-1]}" if self.sequence.present?
  end

  def trimmed_seq_for_display
    "#{self.sequence[self.trimmedReadStart..self.trimmedReadStart+30]...self.sequence[self.trimmedReadEnd-30..self.trimmedReadEnd]}" if self.sequence.present?
  end

  def name_for_display
    if self.name.length > 25
      "#{self.name[0..11]...self.name[-11..-5]}"
    else
      "#{self.name[0..-5]}"
    end
  end

  def default_name
    self.name ||= self.chromatogram.original_filename
  end

  def auto_assign
    #parse name

    msg= nil
    create_issue = false

    #try to find matching primer
    re = /^([A-Za-z0-9]+)(.*)_([A-Za-z0-9-]+)\.(scf|ab1)$/

    m = self.name.match(re)

    if m
      prn = m[3]

      #logic if T7promoter or M13R-pUC.scf:

      if prn == 'T7promoter'
        # get first part out of m[2]
        rgx = /^_([A-Za-z0-9]+)_([A-Za-z0-9]+)$/
        mtchs= m[2].match(rgx) #--> uv2
        prn=mtchs[1]

      elsif prn == 'M13R-pUC'

        # get second part out of m[2] and add "uv"
        # get first part out of m[2]
        rgx = /^_([A-Za-z0-9]+)_([A-Za-z0-9]+)$/
        mtchs= m[2].match(rgx) #--> 4

        #prn='uv'+mtchs[2]  ##--> uv4
        #changed again 13:04 20.09.2014 to match _uv2_uv4

        prn=mtchs[2]  ##--> uv4
      else
        #leave prn as is
      end

      # find & assign primer
      #p = Primer.find_by(:name => prn)

      #changed to mk case insensitive:
      p = Primer.where("primers.name ILIKE ?", "#{prn}").first

      if p

        self.update(:primer_id => p.id, :reverse => p.reverse)

        # find marker that primer belongs to
        ma = p.marker

        if ma

          #try to find matching isolate

          isolate_component = m[1]

          if isolate_component == 'CAR'
            regex = /^_([A-Za-z0-9]+)_(.+)$/
            matches2 = m[2].match(regex)
            isolate_component = matches2[1]
          end

          isolate = Isolate.where("isolates.lab_nr ILIKE ?", "#{isolate_component}").first


          if isolate.nil?
            isolate = Isolate.where("isolates.dna_bank_id ILIKE ?", "#{isolate_component}").first
          end

          if isolate.nil?
            isolate = Isolate.create(:lab_nr => isolate_component)
          end


          self.update(:isolate_id => isolate.id)

          #fig out which contig to assign to

          matching_contig = Contig.where("contigs.marker_id = ? AND contigs.isolate_id = ?", ma.id, isolate.id).first

          if matching_contig

            self.contig=matching_contig
            self.save

            msg = "Assigned to contig #{matching_contig.name}."

          else
            #create new contig, auto assign to primer, copy, auto-name

            ct = Contig.new(:marker_id => ma.id, :isolate_id => isolate.id, :assembled => false)

            ct.generate_name
            ct.save

            self.contig=ct
            self.save

            msg = "Created contig #{ct.name} and assigned primer read to it."

          end

        else
          msg= "No marker assigned to primer #{p.name}."
          create_issue = true
        end
      else
        msg= "Cannot find primer with name #{prn}."
        create_issue = true
      end
    else
      msg= "No match for #{re} in name."
      create_issue = true
    end

    if create_issue
      i=Issue.create(:title => msg, :primer_read_id => self.id)
    else #worked
      self.contig.update(:assembled => false, :assembly_tried => false)
    end

    {:msg => msg, :create_issue => create_issue}

  end

  def get_position_in_marker(p)

    # get position in marker

    pp=nil

    if self.trimmed_seq
      if self.reverse
        pp= p.position-self.trimmed_seq.length
      else
        pp= p.position
      end
    end

    pp
  end

  def s3_credentials
    {:bucket => "gbol5", :access_key_id => "AKIAINH5TDSKSWQ6J62A", :secret_access_key => "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"}
  end

  def copy_to_db

  end

  def auto_trim

    msg=nil
    create_issue = false

    #get local copy from s3

    dest = Tempfile.new(self.chromatogram_file_name)
    dest.binmode
    self.chromatogram.copy_to_local_file(:original, dest.path)

    begin

      chromatogram_ff1 = nil
      p = /\.ab1$/

      if self.chromatogram_file_name.match(p)
        chromatogram_ff1 = Bio::Abif.open(dest.path)
      else
        chromatogram_ff1 = Bio::Scf.open(dest.path)
      end

      chromatogram1 = chromatogram_ff1.next_entry

      if self.reverse
        chromatogram1.complement!()
      end

      sequence = chromatogram1.sequence.upcase

      #copy chromatogram over into db
      if self.sequence.nil?
        self.update(:sequence => sequence)
      end
      if self.qualities.nil?
        self.update(:qualities => chromatogram1.qualities)
      end
      if self.atrace.nil?
        self.update(:atrace => chromatogram1.atrace)
        self.update(:ctrace => chromatogram1.ctrace)
        self.update(:gtrace => chromatogram1.gtrace)
        self.update(:ttrace => chromatogram1.ttrace)
        self.update(:peak_indices => chromatogram1.peak_indices)
      end

      se = Array.new

      se = self.trim_seq(chromatogram1.qualities, self.min_quality_score, self.window_size, self.count_in_window)

      #se = self.trim_seq_inverse(chromatogram1.qualities)

      if se
        if se[0]>=se[1] # trimming has not found any stretch of bases > min_score
          msg='Quality too low - no stretch of readable bases found.'
          create_issue=true
          self.update(:used_for_con => false)
        elsif se[2] > 0.6

          msg="Quality too low - #{(se[2]*100).round}% low-quality base calls in trimmed sequence."
          create_issue=true

          self.update(:used_for_con => false)
        else

          # everything works:

          self.update(:trimmedReadStart => se[0]+1, :trimmedReadEnd => se[1]+1, :used_for_con => true)
          #:position => self.get_position_in_marker(self.primer)
          msg='Sequence trimmed.'
        end
      else
        msg='Quality too low - no stretch of readable bases found.'
        create_issue=true
        self.update(:used_for_con => false)
      end
    rescue
      msg='Sequence could not be trimmed - no scf/ab1 file or no quality scores?'
      create_issue = true
      self.update(:used_for_con => false)
    end

    if create_issue
      i=Issue.create(:title => msg, :primer_read_id => self.id)
      self.update(:used_for_con=>false)
    end

    {:msg => msg, :create_issue => create_issue}

  end

  def trimmed_seq
    if trimmedReadStart.nil? or trimmedReadEnd.nil?
      nil
    else
      if trimmedReadEnd > trimmedReadStart
        raw_sequence = self.sequence[(self.trimmedReadStart-1)..(self.trimmedReadEnd-1)] if self.sequence.present?
        cleaned_sequence = raw_sequence.gsub('-', 'N') # in case basecalls in pherogram have already '-' - as in some crappy seq. I got from BN
      else
        nil
      end
    end
  end

  def trimmed_quals
    if trimmedReadStart.nil? or trimmedReadEnd.nil?
      nil
    else
      if trimmedReadEnd > trimmedReadStart
        trimmed_qual_arr = self.qualities[(self.trimmedReadStart-1)..(self.trimmedReadEnd-1)] if self.qualities.present?
      else
        nil
      end
    end
  end


  #deactivated cause even worse than original
  # def trim_seq_inverse(qualities)
  #
  #   #settings
  #   min_quality_score = 20
  #   c=16
  #   t=20
  #
  #   #final coordinates:
  #
  #   trimmed_read_start = 0
  #   trimmed_read_end = qualities.length
  #
  #   #intermediate coordinates:
  #
  #   trimmed_read_start1 = 0
  #   trimmed_read_end1 = qualities.length
  #
  #   trimmed_read_start2 = qualities.length
  #   trimmed_read_end2 = 0
  #
  #   # --- find readstart:
  #
  #   for i in 0..qualities.length-t
  #     #extract window of size t
  #
  #     count=0
  #
  #     for k in i...i+t
  #       if qualities[k]>=min_quality_score
  #         count += 1
  #       end
  #     end
  #
  #     if count>=c
  #       trimmed_read_start1 = i
  #       break
  #     end
  #
  #   end
  #
  #   # stop when already at seq end
  #   if i >= qualities.length-t
  #     return nil
  #   end
  #
  #   # -- find read-end1, BUT THIS TIME COMING FROM SAME DIRECTION:
  #   #asking: When does quality stop to obey the above quality condition?
  #
  #   for i in trimmed_read_start1..qualities.length-t
  #     #extract window of size t
  #
  #     count=0
  #
  #     for k in i...i+t
  #       if qualities[k]>=min_quality_score
  #         count += 1
  #       end
  #     end
  #
  #     if count<c
  #       trimmed_read_end1 = i
  #       break
  #     end
  #
  #   end
  #
  #   #### same from other dir:
  #
  #   # --- find readend2:
  #
  #   i =qualities.length
  #
  #   while i > 0
  #     #extract window of size t
  #
  #     # k=i
  #     count=0
  #
  #     for k in i-t...i
  #       if qualities[k]>=min_quality_score
  #         count += 1
  #       end
  #     end
  #
  #     if count>=c
  #       trimmed_read_end2 = i
  #       break
  #     end
  #
  #     i-=1
  #
  #   end
  #
  #   # -- find read_start2, BUT THIS TIME COMING FROM SAME DIRECTION:
  #   #asking: When does quality stop to obey the above quality condition?
  #
  #   i =trimmed_read_end2
  #
  #   while i > 0
  #     #extract window of size t
  #
  #     # k=i
  #     count=0
  #
  #     for k in i-t...i
  #       if qualities[k]>=min_quality_score
  #         count += 1
  #       end
  #     end
  #
  #     if count<c
  #       trimmed_read_start2 = i
  #       break
  #     end
  #
  #     i-=1
  #
  #   end
  #
  #
  #   # choose longer fragment
  #
  #   puts trimmed_read_start1
  #   puts trimmed_read_end1
  #
  #   puts trimmed_read_start2
  #   puts trimmed_read_end2
  #
  #
  #
  #   if (trimmed_read_end2-trimmed_read_start2) > (trimmed_read_end1-trimmed_read_start1)
  #     trimmed_read_end=trimmed_read_end2
  #     trimmed_read_start=trimmed_read_start2
  #   else
  #     trimmed_read_end=trimmed_read_end1
  #     trimmed_read_start=trimmed_read_start1
  #   end
  #
  #   #check if xy% < min_score:
  #   ctr_bad=0
  #   ctr_total=0
  #   for j in trimmed_read_start...trimmed_read_end
  #     if qualities[j]<min_quality_score
  #       ctr_bad+=1
  #     end
  #     ctr_total+=1
  #   end
  #
  #   [trimmed_read_start, trimmed_read_end, ctr_bad.to_f/ctr_total.to_f]
  #
  #
  #
  #
  # end


  # old version

  def trim_seq(qualities, min_quality_score, t, c)

    trimmed_read_start = 0
    trimmed_read_end = qualities.length

    # --- find readstart:

    for i in 0..qualities.length-t
      #extract window of size t

      count=0

      for k in i...i+t
        if qualities[k]>=min_quality_score
          count += 1
        end
      end

      if count>=c
        trimmed_read_start = i
        break
      end

    end

    #fine-tune:  if bad bases are at beginning of last window, cut further until current base's score >= min_qual:

    ctr=trimmed_read_start

    for a in ctr..ctr+t
      if qualities[a]>=min_quality_score
        trimmed_read_start = a
        break
      end
    end


    # --- find readend:

    i =qualities.length
    while i > 0
      #extract window of size t

      # k=i
      count=0

      for k in i-t...i
        if qualities[k]>=min_quality_score
          count += 1
        end
      end

      if count>=c
        trimmed_read_end = i
        break
      end

      i-=1

    end

    #fine-tune:  if bad bases are at beginning of last window, go back until current base's score >= min_qual:

    while i > trimmed_read_end-t
      if qualities[i]>=min_quality_score
        break
      end
      i-=1
    end
    trimmed_read_end = i

    #check if xy% < min_score:
    ctr_bad=0
    ctr_total=0
    for j in trimmed_read_start...trimmed_read_end
      if qualities[j]<min_quality_score
        ctr_bad+=1
      end
      ctr_total+=1
    end

    [trimmed_read_start, trimmed_read_end, ctr_bad.to_f/ctr_total.to_f]

  end


end