require 'test_helper'

class Api::V2::AutosignControllerTest < ActionController::TestCase
  setup do
    ProxyAPI::Puppetca.any_instance.stubs(:autosign).returns(["a5809524-82fe-a8a4f3d6ebf4", "5eed0cb7-9aa-00b7b9780f20"])
    @msg = "Test exception"
    @proxy_error = ProxyAPI::ProxyException.new(smart_proxies(:puppetmaster).url, RuntimeError.new, @msg)
  end

  test "should get index and return json" do
    get :index, params: { :smart_proxy_id => smart_proxies(:puppetmaster).id }
    assert_response :success
    assert_equal 'http://else.where:4567/puppet/ca', ProxyAPI::Puppetca.new(:url => smart_proxies(:puppetmaster).url).url
    results = ActiveSupport::JSON.decode(@response.body)
    assert_equal 2, results['results'].length
  end

  test "should create autosign entry" do
    ProxyAPI::Puppetca.any_instance.stubs(:set_autosign).returns(true)
    post :create, params: { :smart_proxy_id => smart_proxies(:puppetmaster).id, :id => "test" }
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['results']
  end

  test "should not create autosign entry" do
    ProxyAPI::Puppetca.any_instance.stubs(:set_autosign).raises(@proxy_error)
    post :create, params: { :smart_proxy_id => smart_proxies(:puppetmaster).id, :id => "test" }
    assert_response :internal_server_error
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['error'].match(@msg)
  end

  test "should delete autosign entry" do
    ProxyAPI::Puppetca.any_instance.stubs(:del_autosign).returns(true)
    post :destroy, params: { :smart_proxy_id => smart_proxies(:puppetmaster).id, :id => "test" }
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['results']
  end

  test "should not delete autosign entry" do
    ProxyAPI::Puppetca.any_instance.stubs(:del_autosign).raises(@proxy_error)
    post :destroy, params: { :smart_proxy_id => smart_proxies(:puppetmaster).id, :id => "test" }
    assert_response :internal_server_error
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['error'].match(@msg)
  end
end
