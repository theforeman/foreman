require 'test_helper'

class ProxyApiTemplateTest < ActiveSupport::TestCase
  def setup
    @url = "http://dummyproxy.theforeman.org:8443"
    @template = ProxyAPI::Template.new({:url => @url})
  end

  test "constructor sets url base path with /unattended" do
    expected = "#{@url}/unattended"
    assert_equal(expected, @template.url)
  end

  test "should get template server url" do
    @template.expects(:get).with('templateServer').returns(fake_rest_client_response({'templateServer' => 'mytemplateserver'}))
    assert_equal('mytemplateserver', @template.template_url)
  end
end
