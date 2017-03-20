require 'test_helper'

class Api::V1::AutosignControllerTest < ActionController::TestCase
  setup do
    ProxyAPI::Puppetca.any_instance.stubs(:autosign).returns(["a5809524-82fe-a8a4f3d6ebf4", "5eed0cb7-9aa-00b7b9780f20"])
  end

  test "should get index and return json" do
    get :index, params: { :smart_proxy_id => smart_proxies(:puppetmaster).id }
    assert_response :success
    assert_equal 'http://else.where:4567/puppet/ca', ProxyAPI::Puppetca.new(:url => smart_proxies(:puppetmaster).url).url
    results = ActiveSupport::JSON.decode(@response.body)
    assert_equal 2, results.length
  end
end
