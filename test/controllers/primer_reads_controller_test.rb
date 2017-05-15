require 'test_helper'

class PrimerReadsControllerTest < ActionController::TestCase
  setup do
    @primer_read = primer_reads(:gbol5127_uv17_uv18_T7promoter)
    user_log_in
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show primer_read" do
    get :show, id: @primer_read
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @primer_read
    assert_response :success
  end

  test "should create primer_read" do
    assert_difference('PrimerRead.count') do
      post :create, primer_read: { name: 'POA_DB11210_BG4110_ITS5.scf', base_count: 774 }
    end

    assert_redirected_to edit_primer_pos_on_genome_path
  end

  test "should update primer_read" do
    patch :update, id: @primer_pos_on_genome, primer_pos_on_genome: { position: '334' }
    assert_redirected_to primer_pos_on_genome_path
  end

  test "should destroy primer_read" do
    assert_difference('PrimerRead.count', -1) do
      delete :destroy, id: @primer_pos_on_genome
    end

    assert_redirected_to primer_pos_on_genomes_url
  end
end