require 'test_helper'

class UnknownResource
end

class FiltersHelperTest < ActionView::TestCase
  include FiltersHelper

  def test_search_path_is_empty_for_nil_resource
    assert_equal '', search_path(nil)
  end

  def test_search_path_is_empty_for_excepted_classes
    %w(Image HostClass).each do |clazz_name|
      assert_equal '', search_path(clazz_name), "class #{clazz_name} doesn't support autocomplete, shouldn't return autocomplete path"
    end
  end

  def test_search_path_for_foreman_model
    assert_equal 'hosts_path/auto_complete_search', search_path('Host')
  end

  def test_should_return_empty_search_path_if_resource_is_not_recognized
    assert_equal '', search_path('UnknownResource')
  end

  def test_engine_search_path_is_used_when_engine_override_available
    with_search_overrides('TestOverride' => ->(resource) { 'test_override/auto_complete_search' })
    assert_equal "test_override/auto_complete_search", search_path('TestOverride::Resource')
  end

  def test_no_deconstantization_if_there_is_no_namespace
    with_search_overrides('TestOverride' => ->(resource) { 'test_override/auto_complete_search' })
    assert_equal "test_override/auto_complete_search", search_path('TestOverride')
  end

  private

  def resource_path(klass)
    (klass == 'Host') ? 'hosts_path' : nil
  end

  def with_search_overrides(search_overrides)
    plugin = mock('ExamplePlugin')
    plugin.expects(:search_overrides).at_least_once.returns(search_overrides)
    Foreman::Plugin.expects(:all).at_least_once.returns([plugin])
  end
end
