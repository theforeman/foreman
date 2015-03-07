require 'test_helper'

class PuppetcaControllerTest < ActionController::TestCase
  test 'problems when signing certificate redirect to back' do
    proxy = smart_proxies(:puppetmaster)
    # Try set any random path in the referer to ensure redirect_to :back
    @request.env['HTTP_REFERER'] = hosts_path
    # This will try to find the certificate to no avail and will raise a ProxyException
    post :update, { :smart_proxy_id => proxy.id, :id => 1 }, set_session_user
    assert_redirected_to @request.env['HTTP_REFERER']
    assert_match /ProxyAPI::ProxyException/, flash[:error]
  end
end
