require 'test_helper'

class Api::V2::TemplateCombinationsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, {:config_template_id => config_templates(:mystring2).id}
    template_combinations = ActiveSupport::JSON.decode(@response.body)
    assert_equal 2, template_combinations.size, "Should contain template_combinations in the response"
    assert_response :success
  end

  test "should get template combination" do
    get :show, { :config_template_id => config_templates(:mystring2).to_param, :id => template_combinations(:two).id }
    assert_response :success
    template_combination = ActiveSupport::JSON.decode(@response.body)
    assert !template_combination.empty?
    assert_equal template_combination["template_combination"]["config_template_id"], template_combinations(:two).config_template_id
  end

  test "should create valid" do
    TemplateCombination.any_instance.stubs(:valid?).returns(true)
    post :create, { :template_combination => { :environment_id => environments(:production).id, :hostgroup_id => hostgroups(:unusual).id },
        :config_template_id => config_templates(:mystring2).id }
    template_combination = ActiveSupport::JSON.decode(@response.body)
    assert template_combination["template_combination"]["environment_id"] == environments(:production).id
    assert template_combination["template_combination"]["hostgroup_id"] == hostgroups(:unusual).id
    assert template_combination["template_combination"]["config_template_id"] == config_templates(:mystring2).id
    assert_response 200
  end

  test "should destroy" do
    delete :destroy, { :config_template_id => config_templates(:mystring2).id, :id => template_combinations(:two).id }
    template = ActiveSupport::JSON.decode(@response.body)

    assert_response :ok
    assert !TemplateCombination.exists?(template_combinations(:two).id)
  end
end
