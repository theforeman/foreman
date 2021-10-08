require 'test_helper'

class SettingRegistryTest < ActiveSupport::TestCase
  let(:registry) { SettingRegistry.instance }
  let(:default) { 5 }
  let(:setting_value) { nil }
  let(:setting) { Setting.create(registry.find('foo').attributes.merge(value: setting_value)) }

  setup do
    registry._add('foo', category: 'Setting::General', default: default, description: 'test foo')
    setting
    registry.load
  end

  context 'with nil default' do
    let(:default) { nil }

    it 'allows nil default value' do
      assert_nil registry['foo']
    end
  end

  describe '#load_values' do
    it "doesn't update definitions for unchanged settings" do
      registry.expects(:find).never

      registry.load_values
    end

    it "updates definitions for changed settings" do
      setting.update(value: 100)
      registry.expects(:find).once

      registry.load_values
    end

    it "can be forced to load all values" do
      registry.expects(:find).times(Setting.count)

      registry.load_values(ignore_cache: true)
    end
  end

  it 'provides default if no value defined' do
    assert_equal 5, registry['foo']
    assert_equal 5, registry[:foo]
  end

  it 'saves the value on assignment' do
    registry[:foo] = 3
    assert Setting.find_by(name: 'foo').persisted?
    assert_equal 3, registry['foo']
  end

  it 'returns updated value only after it is saved' do
    setting.value = 3
    assert_equal 5, registry['foo']

    setting.save
    registry.load
    assert_equal 3, setting.value
    assert_equal 3, registry['foo']
  end

  context 'with value' do
    let(:setting_value) { 10 }

    it 'retrieves the value' do
      assert_equal setting_value, registry['foo']
    end
  end
end
