require 'test_helper'

class TemplatesHelperTest < ActionView::TestCase
  include TemplatesHelper

  test "all safemode helpers should be returned" do
    assert_includes safemode_helpers, Foreman::Renderer.config.allowed_helpers.first.to_s
  end

  test "all safemode variables should be returned" do
    assert_includes safemode_variables, Foreman::Renderer.config.allowed_variables.first.to_s
  end

  test "all safemode jail methods should be returned" do
    assert safemode_methods.any? { |x| x.first == "Host::Managed" }
    assert safemode_methods.any? { |x| x.second.include?("subnet") }
  end
end
