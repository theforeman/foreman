require 'test_helper'

class ProxyReferenceRegistryTest < ActiveSupport::TestCase
  setup do
    @references = ProxyReferenceRegistry.references
    ProxyReferenceRegistry.references = nil
  end

  teardown do
    ProxyReferenceRegistry.references = @references
  end

  test "should add smart proxy reference" do
    refute ProxyReferenceRegistry.references
    ProxyReferenceRegistry.add_smart_proxy_reference(:hosts => [:foo])
    assert_equal [:foo], ProxyReferenceRegistry.references.find { |ref| ref.join_relation == :hosts }.columns
    ProxyReferenceRegistry.add_smart_proxy_reference(:hosts => [:bar])
    assert_equal [:bar, :foo], ProxyReferenceRegistry.references.find { |ref| ref.join_relation == :hosts }.columns.sort
  end

  test "should add correct entries from plugins" do
    Foreman::Plugin.register :test_first_entry_from_plugin do
      smart_proxy_reference :hosts => [:my_test]
    end

    Foreman::Plugin.register :test_second_entry_from_plugin do
      smart_proxy_reference :hosts => [:my_test_again]
    end
    begin
      assert_equal [:my_test, :my_test_again], ProxyReferenceRegistry.find_by_relation(:hosts).columns.sort
    ensure
      Foreman::Plugin.unregister :test_first_entry_from_plugin
      Foreman::Plugin.unregister :test_second_entry_from_plugin
    end
  end
end
