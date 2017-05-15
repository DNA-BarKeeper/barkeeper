require 'test_helper'

class IssuesControllerTest < ActionController::TestCase

  setup do
    @issue = issues(:some_crap_happened)

    user_log_in
  end

  # test "should get index" do
  #   get :index
  #   assert_response :success
  # end
  #
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end
  #
  # test "should create issue" do
  #   assert_difference('Issue.count') do
  #     post :create, issue: { title: 'unexpected error', contig_id: 'verified_contig.id',
  #                            description: 'an unexpected event caused an error' }
  #   end
  #
  # test "should show issue" do
  #   get :show, id: @issue
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get :edit, id: @issue
  #   assert_response :success
  # end
  #
  # test "should update issue" do
  #   patch :update, id: @issue, issue: { title: 'fatal error', contig_id: 'verified_contig.id',
  #                                       description: 'A fatal error occurred.' }
  #   assert_redirected_to issues_path
  # end
  #
  # test "should destroy issue" do
  #   assert_difference('Issue.count', -1) do
  #     delete :destroy, id: @issue
  #   end
  #
  #   assert_redirected_to issues_url
  # end
end