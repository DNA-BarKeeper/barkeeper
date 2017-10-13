class SunburstDiagramController < ApplicationController
  def index
  end

  def data
    root = {:name => 'root', 'children' => []}
    markers = Marker.gbol_marker.select(:id, :name)
    taxa = HigherOrderTaxon.select(:id, :name)

    i = 0
    markers.each do |marker|
      children = root['children']
      children[i] = {:name => marker.name, 'children' => []}
      j = 0
      taxa.each do |taxon|
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
            children4[l] = {:name => family.name, :size => 20}
            l += 1
          end
          k += 1
        end
        j += 1
      end
      i += 1
    end

    render :json => root
    # @hot = HigherOrderTaxon.select(:id, :name)
    # render :json => @hot, :include => [:orders => {:only => :name, :include => {:families => {:only => :name}}}]
  end
end
