require 'test_helper'

class ArchitecturesControllerTest < ActionController::TestCase
  test "?" do
    assert_not_nil ArchitecturesController.active_scaffold_config
    assert ArchitecturesController.active_scaffold_config.model == Architecture
  end

  test "should get index" do
    get :index
    assert_response :success
  end
end
