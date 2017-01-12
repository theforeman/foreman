require 'test_helper'

class PuppetcaControllerTest < ActionController::TestCase
  setup do
    @proxy = smart_proxies(:puppetmaster)
  end

  test 'problems when signing certificate redirect to certificates page' do
    # Try set any random path in the referer to ensure it doesn't redirect_to :back
    @request.env['HTTP_REFERER'] = hosts_path
    # This will try to find the certificate to no avail and will raise a ProxyException
    post :update, { :smart_proxy_id => @proxy.id, :id => 1 }, set_session_user
    assert_redirected_to smart_proxy_path(@proxy, :anchor => 'certificates')
    assert_match(/ProxyAPI::ProxyException/, flash[:error])
  end

  test 'index encodes any CN to an url safe string' do
    cert = SmartProxies::PuppetCACertificate.new(
      ['mcollective/OL=mcollective', 'pending'])
    ProxyStatus::PuppetCA.any_instance.expects(:certs).returns([cert])
    assert_nothing_raised do
      get :index, { :smart_proxy_id => @proxy.id }, set_session_user
    end
    assert_match(/mcollective%252FOL%253Dmcollective/, response.body)
    assert_empty flash[:error]
  end
end
