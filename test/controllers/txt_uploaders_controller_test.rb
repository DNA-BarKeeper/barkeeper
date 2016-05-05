require "test_helper"

class TxtUploadersControllerTest < ActionController::TestCase

  def txt_uploader
    @txt_uploader ||= txt_uploaders :one
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:txt_uploaders)
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    assert_difference('TxtUploader.count') do
      post :create, txt_uploader: {  }
    end

    assert_redirected_to txt_uploader_path(assigns(:txt_uploader))
  end

  def test_show
    get :show, id: txt_uploader
    assert_response :success
  end

  def test_edit
    get :edit, id: txt_uploader
    assert_response :success
  end

  def test_update
    put :update, id: txt_uploader, txt_uploader: {  }
    assert_redirected_to txt_uploader_path(assigns(:txt_uploader))
  end

  def test_destroy
    assert_difference('TxtUploader.count', -1) do
      delete :destroy, id: txt_uploader
    end

    assert_redirected_to txt_uploaders_path
  end
end
