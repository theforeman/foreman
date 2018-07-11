require 'test_helper'
require_relative 'renderers_shared_tests'

class UnsafeModeRendererTest < ActiveSupport::TestCase
  include ::RenderersSharedTests

  def renderer
    @renderer ||= Foreman::Renderer::UnsafeModeRenderer
  end
end
