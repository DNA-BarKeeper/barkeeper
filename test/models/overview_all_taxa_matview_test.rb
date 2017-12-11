require "test_helper"

describe OverviewAllTaxaMatview do
  let(:overview_all_taxa_matview) { OverviewAllTaxaMatview.new }

  it "must be valid" do
    value(overview_all_taxa_matview).must_be :valid?
  end
end
