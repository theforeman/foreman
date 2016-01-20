require 'test_helper'

class DisableTurbolinksRegistryTest < ActiveSupport::TestCase
  setup do
    @registry = DisableTurbolinks::Registry.new
    @registry.register "hosts/show"
  end

  test "should register page" do
    assert_equal 1, @registry.pages.count
  end

  test "should recognize duplicate pages in registry" do
    assert @registry.include?  :controller => "hosts", :action => "show"
  end

  test "should not add duplicate page into registry" do
    @registry.register "hosts/show"
    assert_equal 1, @registry.pages.count
  end

  test "should recognize page by path" do
    assert @registry.has_path? "/hosts/show"
  end
end
