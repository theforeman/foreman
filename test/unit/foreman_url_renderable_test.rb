require "test_helper"

class UrlForemanRenderableTest < ActiveSupport::TestCase

  class Renderer
    include ActionView::Helpers
    include ActionDispatch::Routing
    include Rails.application.routes.url_helpers
    include ::Foreman::Controller::ForemanUrlRenderable

    attr_accessor :host, :template_url
  end

  setup do
    as_admin do
      disable_orchestration # avoids dns errors
      @host = FactoryGirl.create(:host, :managed, :with_dhcp_orchestration, :build => true,
                                            :operatingsystem => operatingsystems(:ubuntu1010),
                                            :ptable => ptables(:ubuntu),
                                            :medium => media(:ubuntu),
                                            :subnet => FactoryGirl.create(:subnet, :tftp),
                                            :architecture => architectures(:x86_64)
                                           )
    end
    @renderer = Renderer.new
  end

  test "should render template_url" do
    token = 'mytoken'
    action = 'action'
    @host.create_token(:value => token, :expires => Time.now + 5.minutes)
    @renderer.host = @host
    @renderer.template_url = "http://www.example.com"
    assert_equal  @renderer.foreman_url(action), "#{@renderer.template_url}:80/unattended/#{action}?token=#{token}"
  end
end
