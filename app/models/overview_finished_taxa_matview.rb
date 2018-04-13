class OverviewFinishedTaxaMatview < ApplicationRecord
  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  def readonly?
    true
  end

  def self.finished_taxa_json(marker_name)
    root = { :name => 'root', 'children' => [] }
    taxa = HigherOrderTaxon.includes(orders: [:families]).order(:position)
    marker_sequence_cnts = OverviewFinishedTaxaMatview.group(:families_name).order(:families_name).sum(marker_name.downcase.gsub('-', '_') + '_cnt')

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
