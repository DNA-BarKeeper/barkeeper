require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe OverviewFinishedTaxa do
  #before(:all) { Project.create(name: 'All') }
  #it_behaves_like "project_record"

  #subject { OverviewFinishedTaxa.new }

  xit "is valid with valid attributes" do
    should be_valid
  end

  context "returns json for finished taxa" do
    xit "returns correct json for finished taxa" do

    end
  end
end