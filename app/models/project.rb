class Project < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :contig_searches
  has_many :marker_sequence_searches

  has_and_belongs_to_many :issues

  has_and_belongs_to_many :primers
  has_and_belongs_to_many :markers

  has_and_belongs_to_many :isolates
  has_and_belongs_to_many :primer_reads
  has_and_belongs_to_many :contigs
  has_and_belongs_to_many :marker_sequences

  has_and_belongs_to_many :individuals
  has_and_belongs_to_many :species
  has_and_belongs_to_many :families
  has_and_belongs_to_many :orders
  has_and_belongs_to_many :higher_order_taxa

  has_and_belongs_to_many :labs
  has_and_belongs_to_many :freezers
  has_and_belongs_to_many :shelves
  has_and_belongs_to_many :lab_racks
  has_and_belongs_to_many :micronic_plates
  has_and_belongs_to_many :plant_plates

  validates_presence_of :name

  def add_project_to_taxa(results)
    results.each do |result|
      result_id = result[0].to_i # searchable_id

      case result[1] # searchable_type
      when 'HigherOrderTaxon'
        add_project_to_hot_rec(result_id)
      when 'Order'
        add_project_to_order_rec(result_id)
      when 'Family'
        add_project_to_family_rec(result_id)
      when 'Species'
        Species.includes(:projects).find(result_id).add_project_and_save(id)
      end
    end
  end

  private

  def add_project_to_hot_rec(hot_id)
    hot = HigherOrderTaxon.includes(:projects).find(hot_id)
    hot.add_project_and_save(id)
    hot.orders.each { |o| add_project_to_order_rec(o.id) }
  end

  def add_project_to_order_rec(order_id)
    order = Order.includes(:projects).find(order_id)
    order.add_project_and_save(id)
    order.families.each { |f| add_project_to_family_rec(f.id) }
  end

  def add_project_to_family_rec(family_id)
    family = Family.includes(:projects).find(family_id)
    family.add_project_and_save(id)
    family.species.each { |s| s.add_project_and_save(id) }
  end
end
