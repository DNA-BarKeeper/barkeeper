class MarkerSequence < ActiveRecord::Base
  belongs_to :isolate
  has_many :contigs
  belongs_to :marker
  #validates_presence_of :sequence

  def self.in_higher_order_taxon(higher_order_taxon_id)
    count=0

    HigherOrderTaxon.find(higher_order_taxon_id).orders.each do |ord|
      ord.families.each do |fam|
        fam.species.each do  |sp|
          sp.individuals.each do |ind|
            ind.isolates.each do |iso|
              count+=iso.marker_sequences.count
            end
          end
        end
      end
    end

    count
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
