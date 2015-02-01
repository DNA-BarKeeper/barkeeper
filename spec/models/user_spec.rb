require 'spec_helper'

describe User do

  # pending "add some examples to (or delete) #{__FILE__}"
  before { @user = User.new(name: "Example User", email: "user@example.com") }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }

  # it { should be_valid }
  #
  # describe "when name is not present" do
  #   before { @user.name = " " }
  #   it { should_not be_valid }
  # end

end
