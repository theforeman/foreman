require 'test_helper'

class CacheManagerTest < ActiveSupport::TestCase
  test 'new filter cache can be created regardless of locked roles' do
    as_admin do
      assert Role.any?(&:locked?)
      CacheManager.create_new_filter_cache
    end
  end
end
