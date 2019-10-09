# frozen_string_literal: true

module HigherOrderTaxaHelper
  def nested_taxa(higher_order_taxa)
    higher_order_taxa.map do |taxon, sub_taxa|
      render(taxon) + content_tag(:div, nested_taxa(sub_taxa), :class => "nested_taxa")
    end.join.html_safe
  end
end