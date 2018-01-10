require "test_helper"

describe OverviewFinishedTaxaMatview do
  let(:overview_finished_taxa_matview) { OverviewFinishedTaxaMatview.new }

  it "must be valid" do
    value(overview_finished_taxa_matview).must_be :valid?
  end
end
