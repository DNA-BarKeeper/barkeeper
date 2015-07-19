require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  test 'should not save project without title' do
    project=Project.new
    assert_not project.save, 'Saved the project without a title'
  end

  test 'user should be assignable to project' do
    # p=Project.create(:name => 'Project1')
    p=projects(:gbol5)
    u=User.new(:name => 'Hans Wurst', :email => 'test@example.com', :password => 'password', :password_confirmation => 'password')

    # this should load fixture but currently doesnt:
    # are fixtures not loaded?

    # u=users(:first_test_user)


    p.users << u
    assert_equal(1, p.users.count, 'User could not be assigned to project')
    u.destroy
  end

  # test 'should be possible to assign individual to project' do
  #   p=Project.create(:name => 'Project1')
  #   individual=Individual.create(:specimen_id => "dsfghjödlkfjsa2345")
  #   p.individuals << individual
  #   assert_equal(1, p.individuals.count, 'Individual could not be assigned to project')
  # end

end
