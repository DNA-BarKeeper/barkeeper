# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:

ActiveSupport::Inflector.inflections(:en) do |inflect|
  #   inflect.plural /^(ox)$/i, '\1en'
  #   inflect.singular /^(ox)en/i, '\1'
  #   inflect.irregular 'person', 'people'
  #    inflect.uncountable %w( fish sheep )
  inflect.irregular 'taxon', 'taxa'
  inflect.irregular 'syntaxon', 'syntaxa'
  inflect.irregular 'OverviewFinishedTaxa', 'OverviewFinishedTaxa'
  inflect.irregular 'OverviewAllTaxa', 'OverviewAllTaxa'
  inflect.irregular 'overview_finished_taxa', 'overview_finished_taxa'
  inflect.irregular 'overview_all_taxa', 'overview_all_taxa'
  inflect.irregular 'HigherOrderTaxon', 'HigherOrderTaxa'
  inflect.irregular 'higher_order_taxon', 'higher_order_taxa'
  inflect.irregular 'genus', 'genera'
  inflect.uncountable %w[species]
  inflect.uncountable %w[subspecies]
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
