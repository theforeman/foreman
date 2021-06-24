require 'test_helper'
require_relative 'renderers_shared_tests'

class SafeModeRendererTest < ActiveSupport::TestCase
  include ::RenderersSharedTests

  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
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

    assert_include exception.message, 'parse error on value ")"'
  end

  test "application record allowed methods" do
    assert ::ApplicationRecord::Jail.allowed? :name
    assert ::ApplicationRecord::Jail.allowed? :present?
  end

  test "application record child allowed methods" do
    assert ::Domain::Jail.allowed? :name
    assert ::Domain::Jail.allowed? :fullname
    assert ::Domain::Jail.allowed? :present?
  end
end
