require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  setup do
    @project = projects(:gbol5)
    @user = users(:default)
  end

  test 'should not save project without title' do
    project=Project.new
    assert_not project.save, 'Saved the project without a title'
  end

  test 'user should be assignable to project' do
    @project.users << @user
    assert_equal(1, @project.users.count, 'User could not be assigned to project')
  end

  test 'it should be possible to assign individual to project' do
    individual=Individual.create(:specimen_id => 'dsfghjödlkfjsa2345')
    @project.individuals << individual
    assert_equal(1, @project.individuals.count, 'Individual could not be assigned to project')
  end

end
