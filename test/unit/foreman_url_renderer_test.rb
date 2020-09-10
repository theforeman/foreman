require "test_helper"

class ForemanUrlRendererTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  class Renderer
    include ActionView::Helpers
    include ActionDispatch::Routing
    include ::Foreman::ForemanUrlRenderer

    attr_accessor :host, :template_url
  end

  let(:host) { FactoryBot.build_stubbed(:host, :managed, :with_dhcp_orchestration, :with_build) }
  let(:renderer) { Renderer.new }
  let(:action) { 'provision' }

  context 'with token' do
    let(:token) { '1234abc' }
    setup do
      host.build_token(:value => token, :expires => Time.zone.now + 5.minutes)
    end

    test "should render template_url with unattended url" do
      Setting[:unattended_url] = 'http://www.example.net'
      renderer.host = host
      assert_equal "#{Setting[:unattended_url]}/unattended/#{action}?token=#{token}", renderer.foreman_url(action)
    end

    test "should render template_url with unattended url with a parameter" do
      Setting[:unattended_url] = 'http://www.example.net'
      renderer.host = host
      assert_equal "#{Setting[:unattended_url]}/unattended/#{action}?test=987&token=#{token}", renderer.foreman_url(action, test: 987)
    end

    test "should render template_url with unattended url with a parameter without a token" do
      host.stubs(:token).returns(nil)
      Setting[:unattended_url] = 'http://www.example.net'
      renderer.host = host
      assert_equal "#{Setting[:unattended_url]}/unattended/#{action}?test=987", renderer.foreman_url(action, test: 987)
    end

    test "should render template_url with template_url variable" do
      renderer.host = host
      renderer.template_url = "http://www.example.com"
      assert_equal "#{renderer.template_url}/unattended/#{action}?token=#{token}", renderer.foreman_url(action)
    end

    test "should render template_url with templates proxy" do
      template_server_from_proxy = 'https://someproxy:8443'
      proxy = FactoryBot.build_stubbed(:template_smart_proxy, :url => 'https://template.proxy:8443')

      stub_request(:get, "https://template.proxy:8443/unattended/templateServer").
         to_return(status: 200, body: "{\"templateServer\":\"#{template_server_from_proxy}\"}")

      host.subnet.template = proxy
      renderer.host = host
      assert_equal "#{template_server_from_proxy}/unattended/#{action}?token=#{token}", renderer.foreman_url(action)
      assert_requested(:get, "https://template.proxy:8443/unattended/templateServer", times: 1)
    end
  end
end
