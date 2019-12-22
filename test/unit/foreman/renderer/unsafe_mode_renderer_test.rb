require 'test_helper'
require_relative 'renderers_shared_tests'

class UnsafeModeRendererTest < ActiveSupport::TestCase
  include ::RenderersSharedTests

  def renderer
    @renderer ||= Foreman::Renderer::UnsafeModeRenderer
  end

  test "should raise renderer syntax error on syntax error" do
    template_content = <<~EOS
      line 1: ok
      line 2: ok
      line 3: <%= 1 + %>
      line 4: ok
    EOS

    source = OpenStruct.new(name: 'my_template', content: template_content)

    exception = assert_raises Foreman::Renderer::Errors::SyntaxError do
      renderer.render(source, @scope)
    end

    assert_include exception.message, 'my_template:3'
    assert_include exception.message, "syntax error, unexpected ')'"
  end
end
