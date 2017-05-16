require 'test_helper'

class ContigsControllerTest < ActionController::TestCase
  setup do
    @contig = contigs(:unverified_contig)
    user_log_in
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show contig" do
    get :show, id: @contig
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contig
    assert_response :success
  end
  #
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  test "should update contig" do
    patch :update, id: @contig, contig: { name: 'gbol5127_rpl16' }
    assert_redirected_to edit_contig_path(@contig)
  end

  test "should destroy contig" do
    assert_difference('Contig.count', -1) do
      delete :destroy, id: @contig
    end

    assert_redirected_to contigs_url
  end

  test "should create contig" do
    assert_difference('Contig.count') do
      post :create, contig: {id: 5, name: 'GBoL3544_trnK-matK', pde: ''}
    end

    assert_redirected_to contig_path(assigns(:contig))
  end
end