require 'test_helper'

class ContigsControllerTest < ActionController::TestCase
  setup do
    @contig = contigs_data(:unverified_contig)
    user_log_in
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show contig" do
    get :show, params: { id: @contig }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @contig }
    assert_response :success
  end

  test "should update contig" do
    patch :update, params: { id: @contig, contig: { name: 'gbol5127_rpl16' } }
    assert_redirected_to edit_contig_path(@contig)
  end

  test "should destroy contig" do
    assert_difference('Contig.count', -1) do
      delete :destroy, params: { id: @contig }
    end

    assert_redirected_to contigs_url
  end
end