require 'test_helper'

class PrimerReadsControllerTest < ActionController::TestCase
  setup do
    @primer_read = primer_reads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:primer_reads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create primer_read" do
    assert_difference('PrimerRead.count') do
      post :create, primer_read: {  }
    end

    assert_redirected_to primer_read_path(assigns(:primer_read))
  end

  test "should show primer_read" do
    get :show, id: @primer_read
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @primer_read
    assert_response :success
  end

  test "should update primer_read" do
    patch :update, id: @primer_read, primer_read: {  }
    assert_redirected_to primer_read_path(assigns(:primer_read))
  end

  test "should destroy primer_read" do
    assert_difference('PrimerRead.count', -1) do
      delete :destroy, id: @primer_read
    end

    assert_redirected_to primer_reads_path
  end
end
