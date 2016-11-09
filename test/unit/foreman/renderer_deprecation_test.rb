require 'test_helper'

class RendererTest < ActiveSupport::TestCase
  class DummyRenderer
    attr_accessor :host

    include Foreman::Renderer
  end

  test 'should show the deprecation for @host.info' do
    renderer = DummyRenderer.new
    renderer.host = FactoryGirl.create(:host, :with_puppet)
    template = FactoryGirl.create(:provisioning_template, :template => '<%= @host.info %>')
    Rails.logger.expects(:warn).with("DEPRECATION WARNING: you are using deprecated @host.info in a template, it will be removed in 1.17. Use host_enc instead.").once
    renderer.unattended_render template
  end

  test 'should show the deprecation for @host.params' do
    renderer = DummyRenderer.new
    renderer.host = FactoryGirl.create(:host, :with_puppet)
    template = FactoryGirl.create(:provisioning_template, :template => '<%= @host.params %>')
    Rails.logger.expects(:warn).with("DEPRECATION WARNING: you are using deprecated @host.params in a template, it will be removed in 1.17. Use host_param instead.").once
    renderer.unattended_render template
  end

  test 'should render host param using "host_param" helper without deprecation' do
    renderer = DummyRenderer.new
    renderer.host = FactoryGirl.create(:host, :with_puppet)
    Rails.logger.expects(:warn).never
    assert renderer.render_safe("<%= host_param('test') %>", DummyRenderer::ALLOWED_HELPERS).present?
  end

  test 'should render host info using "host_enc" helper without deprecation' do
    renderer = DummyRenderer.new
    renderer.host = FactoryGirl.create(:host, :with_puppet)
    Rails.logger.expects(:warn).never
    assert renderer.render_safe("<%= host_enc %>", DummyRenderer::ALLOWED_HELPERS).present?
  end
end
