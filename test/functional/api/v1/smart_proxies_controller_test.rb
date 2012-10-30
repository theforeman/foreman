require 'test_helper'

class Api::V1::SmartProxiesControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:smart_proxies)
    smart_proxies = ActiveSupport::JSON.decode(@response.body)
    assert !smart_proxies.empty?
  end

  test "should show individual record" do
    as_user :admin do
      get :show, {:id => smart_proxies(:one).to_param}
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

end
