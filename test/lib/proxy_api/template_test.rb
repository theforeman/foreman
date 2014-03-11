require 'test_helper'

class ProxyApiTemplateTest < ActiveSupport::TestCase
  def setup
    @url = "http://localhost:8443"
    @template = ProxyAPI::Template.new({:url => @url})
  end

  def fake_response(data)
    net_http_resp = Net::HTTPResponse.new(1.0, 200, "OK")
    net_http_resp.add_field 'Set-Cookie', 'Monster'
    RestClient::Response.create(JSON(data), net_http_resp, nil)
  end

  test "constructor should complete" do
    assert_not_nil(@template)
  end

  test "base url should equal /unattended" do
    expected = "#{@url}/unattended"
    assert_equal(expected, @template.url)
  end

  test "should get template server url" do
    @template.expects(:get).with('templateServer').returns(fake_response({'templateServer'=>'mytemplateserver'}))
    assert_equal('mytemplateserver', @template.template_url)
  end

end
