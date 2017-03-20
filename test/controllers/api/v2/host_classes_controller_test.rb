require 'test_helper'

class Api::V2::HostClassesControllerTest < ActionController::TestCase
  def setup
    @host = FactoryBot.create(:host, :with_puppetclass)
  end

  test "should get puppetclass ids for host" do
    get :index, params: { :host_id => @host.to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses['results'].empty?
    assert_equal puppetclasses['results'].length, 1
  end

  test "should add a puppetclass to a host" do
    assert_difference('@host.host_classes.count') do
      post :create, params: { :host_id => @host.to_param, :puppetclass_id => puppetclasses(:four).id }
    end
    assert_response :success
  end

  test "should remove a puppetclass from a host" do
    assert_difference('@host.host_classes.count', -1) do
      delete :destroy, params: { :host_id => @host.to_param, :id => @host.host_classes.first.puppetclass_id }
    end
    assert_response :success
  end
end
