require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe OverviewAllTaxa do
  #before(:all) { Project.create(name: 'All') }
  #it_behaves_like "project_record"

  #subject { OverviewAllTaxa.new }

  xit "is valid with valid attributes" do
    should be_valid
  end

  context "returns json for all taxa" do
    xit "returns correct json for all taxa" do

    end
  end
end