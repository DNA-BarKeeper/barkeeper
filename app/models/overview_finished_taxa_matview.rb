class OverviewFinishedTaxaMatview < ApplicationRecord
  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  def readonly?
    true
  end

  def self.finished_taxa_json
    root = {:name => 'root', 'children' => []}
    markers = Marker.gbol_marker.select(:id, :name)
    data = HigherOrderTaxon.includes(orders: [:families])

    i = 0
    markers.each do |marker|
      marker_sequence_cnts = OverviewFinishedTaxaMatview.group(:families_name).sum(marker.name.downcase.gsub('-', '_') + '_cnt')

      children = root['children']
      children[i] = { :name => marker.name, 'children' => [] }
      j = 0
      data.each do |taxon|
        orders = taxon.orders
        children2 = children[i]['children']
        children2[j] = { :name => taxon.name, 'children' => [] }
        k = 0
        orders.each do |order|
          families = order.families
          children3 = children2[j]['children']
          children3[k] = { :name => order.name, 'children' => [] }
          l = 0
          families.each do |family|
            children4 = children3[k]['children']
            children4[l] = { name: family.name, size: marker_sequence_cnts[family.name].to_i }
            l += 1
          end
          k += 1
        end
        j += 1
      end
      i += 1
    end

    root
  end
end