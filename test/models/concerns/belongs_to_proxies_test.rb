require 'test_helper'

class BelongsToProxiesTest < ActiveSupport::TestCase
  class SampleModel
    include BelongsToProxies

    class << self
      def belongs_to(name, options = {})
      end

      def validates(name, options = {})
      end
    end

    belongs_to_proxy :foo, :feature => 'Foo'
  end

  class EmptySampleModel
    include BelongsToProxies
  end

  setup :clear_plugins

  test '#registered_smart_proxies has default value' do
    assert_equal({}, EmptySampleModel.registered_smart_proxies)
  end

  test '#registered_smart_proxies contains foo proxy' do
    assert_equal({:foo => {:feature => 'Foo'}}, SampleModel.registered_smart_proxies)
  end

  test '#registered_smart_proxies contains foo proxy and bar proxy from plugin' do
    class SampleModelOne < SampleModel; end
    Foreman::Plugin.register :test_smart_proxy do
      name 'Smart Proxy test'
      smart_proxy_for SampleModelOne, :bar, :feature => 'Bar'
    end
    expected = {
      :foo => {:feature => 'Foo'},
      :bar => {:feature => 'Bar'},
    }
    assert_equal expected, SampleModelOne.registered_smart_proxies
  end

  test '#registered_smart_proxies are inherited from parent class' do
    class SampleModelTwo < SampleModel; end
    assert_equal SampleModel.registered_smart_proxies, SampleModelTwo.registered_smart_proxies
  end

  test '#registered_smart_proxies can be extended for subclass only' do
    class SampleModelThree < SampleModel; end
    Foreman::Plugin.register :test_smart_proxy do
      name 'Smart Proxy test'
      smart_proxy_for SampleModelThree, :baz, :feature => 'Baz'
    end

    refute_includes SampleModel.registered_smart_proxies.keys, :baz
    assert_includes SampleModelThree.registered_smart_proxies.keys, :baz
  end
end
