require 'test_helper'

class TemplatesHelperTest < ActionView::TestCase
  include TemplatesHelper

  test "all safemode helpers should be returned" do
    assert_includes safemode_helpers, Foreman::Renderer::ALLOWED_HELPERS.first.to_s
  end

  test "all safemode variables should be returned" do
    assert_includes safemode_variables, Foreman::Renderer::ALLOWED_VARIABLES.first.to_s
  end

  test "all safemode jail methods should be returned" do
    assert safemode_methods.any?{ |x| x.first == "Host::Managed" }
    assert safemode_methods.any?{ |x| x.second.include?("subnet") }
  end
end
