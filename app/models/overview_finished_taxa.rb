class OverviewFinishedTaxa < ApplicationRecord
  include ProjectRecord

  def self.finished_taxa_json(current_project_id, marker_id)
    root = { :name => 'root', 'children' => [] }
    taxa = HigherOrderTaxon.in_project(current_project_id).includes(orders: [:families]).order(:position)
    marker_sequence_cnts = MarkerSequence.in_project(current_project_id).joins(isolate: [individual: [species: :family]]).where(:marker => marker_id).order('families.name').group('families.name').count

    i = 0
    taxa.each do |taxon|
      orders = taxon.orders
      children = root['children']
      children[i] = { :name => taxon.name, 'children' => [] }
      j = 0
      orders.each do |order|
        families = order.families
        children2 = children[i]['children']
        children2[j] = { :name => order.name, 'children' => [] }
        k = 0
        families.each do |family|
          children3 = children2[j]['children']
          children3[k] = { name: family.name, size: marker_sequence_cnts[family.name].to_i }
          k += 1
        end
        j += 1
      end
      i += 1
    end

    root
  end
end
