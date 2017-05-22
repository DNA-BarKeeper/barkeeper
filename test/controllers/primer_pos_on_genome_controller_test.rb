require 'test_helper'

class PrimerPosOnGenomesControllerTest < ActionController::TestCase
  setup do
    @primer_pos_on_genome = primer_pos_on_genomes(:position1)
    user_log_in
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show primer position on genome" do
    get :show, params: { id: @primer_pos_on_genome }
    assert_response :success
  end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get :edit, id: @primer_pos_on_genome
  #   assert_response :success
  # end

  # test "should create primer position on genome" do
  #   assert_difference('PrimerPosOnGenome.count') do
  #     post :create, primer_pos_on_genome: { position: '767' }
  #   end
  #
  #   assert_redirected_to edit_primer_pos_on_genome_path
  # end

  test "should update primer position on genome" do
    patch :update, params: { id: @primer_pos_on_genome, primer_pos_on_genome: { position: '334' } }
    assert_redirected_to primer_pos_on_genome_path
  end

  test "should destroy primer position on genome" do
    assert_difference('PrimerPosOnGenome.count', -1) do
      delete :destroy, params: { id: @primer_pos_on_genome }
    end

    assert_redirected_to primer_pos_on_genomes_url
  end
end