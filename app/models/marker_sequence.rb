class MarkerSequence < ApplicationRecord
  belongs_to :isolate
  has_many :contigs
  belongs_to :marker
  #validates_presence_of :sequence

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)

    ms=MarkerSequence.select("species_id").includes(:isolate => :individual).joins(:isolate => {:individual => {:species => {:family => {:order => :higher_order_taxon}}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    ms_s=MarkerSequence.select("species_component").includes(:isolate => :individual).joins(:isolate => {:individual => {:species => {:family => {:order => :higher_order_taxon}}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    ms_i=MarkerSequence.select("individual_id").includes(:isolate => :individual).joins(:isolate => {:individual => {:species => {:family => {:order => :higher_order_taxon}}}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    [ms.count, ms_s.uniq.count, ms.uniq.count, ms_i.uniq.count]
  end



  def generate_name
    if self.marker.present? and self.isolate.present?
      self.update(:name => "#{self.isolate.lab_nr}_#{self.marker.name}")
    else
      self.update(:name=>'<unnamed>')
    end
  end

  def isolate_lab_nr
    isolate.try(:lab_nr)
  end

  def isolate_lab_nr=(lab_nr)
    if lab_nr == ''
      self.isolate = nil
    else
      self.isolate = Isolate.find_or_create_by(:lab_nr => lab_nr) if lab_nr.present?
    end
  end

end
