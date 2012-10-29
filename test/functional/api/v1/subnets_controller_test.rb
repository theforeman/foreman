require 'test_helper'

class Api::V1::SubnetsControllerTest < ActionController::TestCase
  def test_index
    as_admin { get :index }
    subnets = ActiveSupport::JSON.decode(@response.body)
    assert subnets.is_a?(Array)
    assert_response :success
    assert !subnets.empty?

  end

end
