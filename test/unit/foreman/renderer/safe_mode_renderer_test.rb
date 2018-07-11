require 'test_helper'
require_relative 'renderers_shared_tests'

class SafeModeRendererTest < ActiveSupport::TestCase
  include ::RenderersSharedTests

  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end
end
