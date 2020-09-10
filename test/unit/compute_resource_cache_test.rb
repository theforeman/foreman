require 'test_helper'

class ComputeResourceCacheTest < ActiveSupport::TestCase
  let(:compute_resource) { compute_resources(:vmware) }
  let(:cache) { ComputeResourceCache.new(compute_resource) }

  context 'with caching enabled' do
    setup do
      compute_resource.caching_enabled = true
    end

    test 'it caches data' do
      mock_networks = {'net' => 'work'}
      compute_resource.expects(:networks).once.returns(mock_networks)
      values = Array.new(10) do
        cache.cache(:networks) do
          networks
        end
      end
      assert_equal mock_networks, values.first
      assert_equal 1, values.uniq.size
    end

    test 'refresh the cache' do
      initial_scope = cache.cache_scope
      initial_value = 'testvalue'
      cache.write(:test, initial_value)
      cache.refresh
      new_scope = cache.cache_scope
      assert_not_equal initial_scope, new_scope
      assert_nil cache.read(:test)
    end

    test '#delete deletes keys from the cache' do
      cache.write(:delete_test, 'Foreman is great.')
      cache.delete(:delete_test)
      assert_nil cache.read(:delete_test)
    end

    test '#write and #read store and read data in the cache' do
      message = "Foreman is super."
      cache.write(:write_test, message)
      assert_equal message, cache.read(:write_test)
    end
  end

  context 'with caching disabled' do
    setup do
      compute_resource.caching_enabled = false
    end

    test 'does not cache data' do
      mock_networks = {'net' => 'work'}
      Rails.cache.expects(:write).never
      Rails.cache.expects(:read).never
      Rails.cache.expects(:fetch).never
      compute_resource.expects(:networks).times(10).returns(mock_networks)
      values = Array.new(10) do
        cache.cache(:networks) do
          networks
        end
      end
      assert_equal mock_networks, values.first
      assert_equal 1, values.uniq.size
    end
  end
end
