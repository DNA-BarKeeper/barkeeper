class OverviewAllTaxaMatview < ApplicationRecord
  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  def readonly?
    true
  end

  def all_species
    root = {:name => 'root', 'children' => []}
    markers = Marker.gbol_marker.select(:id, :name)
    # data = HigherOrderTaxon.includes(orders: [families: [:species]])

    i = 0
    markers.each do |marker|
      children = root['children']
      children[i] = {:name => marker.name, 'children' => []}
      j = 0
      OverviewAllTaxaMatview.hot.each do |taxon|
        orders = taxon.orders
        children2 = children[i]['children']
        children2[j] = {:name => taxon.name, 'children' => []}
        k = 0
        orders.each do |order|
          families = order.families
          children3 = children2[j]['children']
          children3[k] = {:name => order.name, 'children' => []}
          l = 0
          families.each do |family|
            children4 = children3[k]['children']
            children4[l] = {:name => family.name, :size => family.species.count}
            l += 1
          end
          k += 1
        end
        j += 1
      end
      i += 1
    end

    return root.as_json
  end

  def finished_species
    root = {:name => 'root', 'children' => []}
    markers = Marker.gbol_marker.select(:id, :name)
    data = HigherOrderTaxon.includes(orders: [:families])

    i = 0
    markers.each do |marker|
      children = root['children']
      children[i] = {:name => marker.name, 'children' => []}
      j = 0
      data.each do |taxon|
        orders = taxon.orders
        children2 = children[i]['children']
        children2[j] = {:name => taxon.name, 'children' => []}
        k = 0
        orders.each do |order|
          families = order.families
          children3 = children2[j]['children']
          children3[k] = {:name => order.name, 'children' => []}
          l = 0
          families.each do |family|
            children4 = children3[k]['children']
            children4[l] = {:name => family.name, :size => family.completed_species_cnt(marker.id)}
            l += 1
          end
          k += 1
        end
        j += 1
      end
      i += 1
    end

    return root.as_json
  end
end
