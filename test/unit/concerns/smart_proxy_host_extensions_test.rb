require 'test_helper'

class SmartProxyHostExtensionsTest < ActiveSupport::TestCase
  setup do
    @references = ProxyReferenceRegistry.references
    ProxyReferenceRegistry.references = nil

    class ProxyReferrer
      include SmartProxyHostExtensions
      smart_proxy_reference :test_reference => [:test]
      smart_proxy_reference :test_reference => [:another_test]
    end
  end

  teardown do
    ProxyReferenceRegistry.references = @references
  end

  test "should have test_reference" do
    assert ProxyReferenceRegistry.find_by_relation(:test_reference)
  end

  test "should join references" do
    assert_equal 1, ProxyReferenceRegistry.smart_proxy_references.length
    assert_equal [:another_test, :test], ProxyReferenceRegistry.find_by_relation(:test_reference).columns.sort
  end

  test "should not overwrite references" do
    ProxyReferrer.smart_proxy_reference :additional_reference => [:yet_another_test]
    assert_equal 2, ProxyReferenceRegistry.smart_proxy_references.length
  end
end
