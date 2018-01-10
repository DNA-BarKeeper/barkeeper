class OverviewDiagramController < ApplicationController
  def index
  end

  # returns JSON containing the number of target species for each family
  def all_species
    root = {:name => 'root', 'children' => []}
    markers = Marker.gbol_marker.select(:id, :name)

    data = HigherOrderTaxon.includes(orders: [families: [:species]])
    families_mat = OverviewAllTaxaMatview.group(:family).sum(:species_cnt)

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
            children4[l] = {:name => family.name, :size => families_mat[family.name].to_i}
            l += 1
          end
          k += 1
        end
        j += 1
      end
      i += 1
    end

    render :json => root
  end

  # returns JSON with the number of finished species for each family
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

    render :json => root
  end
end
