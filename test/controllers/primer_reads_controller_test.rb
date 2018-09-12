# frozen_string_literal: true

require 'test_helper'

class PrimerReadsControllerTest < ActionController::TestCase
  setup do
    @primer_read = primer_reads(:original_read)
    user_log_in
  end

  test 'should get reads without contigs' do
    get :reads_without_contigs
    assert_response :success
  end

  test 'should get duplicate reads' do
    get :duplicates
    assert_response :success
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should show primer read' do
    get :show, params: { id: @primer_read }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @primer_read }
    assert_response :success
  end

  test 'should get assign' do
    get :assign, params: { id: @primer_read }
    assert_redirected_to edit_primer_read_path
  end

  test 'should get reverse' do
    get :assign, params: { id: @primer_read }
    assert_redirected_to edit_primer_read_path
  end

  test 'should get restore' do
    get :assign, params: { id: primer_reads(:reverse_read) }
    assert_redirected_to edit_primer_read_path
  end

  test 'should update primer read' do
    patch :update, params: { id: @primer_read, primer_read: { base_count: 774 } }
    assert_redirected_to edit_primer_read_path
  end

  test 'should destroy primer read' do
    assert_difference('PrimerRead.count', -1) do
      delete :destroy, params: { id: @primer_read }
    end

    assert_redirected_to primer_reads_url
  end
end
