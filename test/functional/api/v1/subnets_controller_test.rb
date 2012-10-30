require 'test_helper'

class Api::V1::SubnetsControllerTest < ActionController::TestCase
  def test_index
    as_admin { get :index }
    subnets = ActiveSupport::JSON.decode(@response.body)
    assert subnets.is_a?(Array)
    assert_response :success
    assert !subnets.empty?

  end

  test "should show individual record" do
    as_user :admin do
      get :show, {:id => subnets(:one).to_param}
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end


end
