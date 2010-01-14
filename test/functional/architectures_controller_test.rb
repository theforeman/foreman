require 'test_helper'

class ArchitecturesControllerTest < ActionController::TestCase
  def setup
    @controller = ArchitecturesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  test "ActiveScaffold should look for Architecture model" do
    assert_not_nil ArchitecturesController.active_scaffold_config
    assert ArchitecturesController.active_scaffold_config.model == Architecture
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "shuold get new" do
    get :new
    assert_response :success
  end

  test "should create new architecture" do
    assert_difference 'Architecture.count' do
      post :create, :architecture => {:name => "some_arch"}
    end

    assert_redirected_to architecture_path(assigns[:architecture])
  end
end
