require 'test_helper'

class RendererTest < ActiveSupport::TestCase
  class DummyRenderer
    attr_accessor :host

    include Foreman::Renderer
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
