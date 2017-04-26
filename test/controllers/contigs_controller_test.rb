require 'test_helper'

class ContigsControllerTest < ActionController::TestCase
  setup do
    @contig = contigs(:gbol5127_matk)
    user_log_in
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show contig" do
    get :show, contig: @contig
    assert_response :success
  end

  test "should get edit" do
    get :edit, contig: @contig
    assert_response :success
  end

  test "should update contig" do
    patch :update, id: @contig, contig: { name: 'gbol5127_rpl16' }
    assert_redirected_to contig_path(assigns(:contig))
  end

  test "should destroy contig" do
    assert_difference('Contig.count', -1) do
      delete :destroy, id: @contig
    end

    assert_redirected_to individuals_path
  end
end