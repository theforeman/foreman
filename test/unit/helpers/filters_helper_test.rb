require 'test_helper'

module FiltersHelperTestModule
  class FiltersHelper
    def self.search_path(type)
      "engine/auto_complete_search"
    end
  end
end

class UnknownResource
end

class FiltersHelperTest < ActionView::TestCase
  include FiltersHelper

  def test_search_path_is_empty_for_nil_resource
    assert_equal '', search_path(nil)
  end

  def test_search_path_is_empty_for_excepted_classes
    %w(Image HostClass Parameter).each do |clazz_name|
      assert_equal '', search_path(clazz_name), "class #{clazz_name} doesn't support autocomplete, shouldn't return autocomplete path"
    end
  end

  def test_search_path_for_foreman_model
    expects(:resource_path).with('Host').returns('hosts_path')
    assert_equal 'hosts_path/auto_complete_search', search_path('Host')
  end

  def test_engine_search_path_is_used_when_engine_override_available
    assert_equal 'engine/auto_complete_search', search_path('FiltersHelperTestModule::Resource')
  end

  def test_default_search_path_is_used_when_engine_override_not_available
    expects(:resource_path).with('Engine::Host').returns('hosts_path')
    assert_equal 'hosts_path/auto_complete_search', search_path('Engine::Host')
  end

  def test_should_return_empty_search_path_if_resource_is_not_recognized
    assert_equal '', search_path('UnknownResource')
  end
end
