require 'test_helper'

class SettingRegistryTest < ActiveSupport::TestCase
  let(:registry) { SettingRegistry.instance }
  let(:default) { 5 }
  let(:setting_value) { nil }
  let(:setting_memo) { {} }
  let(:setting) { Setting.create(registry.find('foo').attributes) }

  setup do
    registry.stubs(settings: setting_memo)
    registry._add('foo', type: :integer, category: 'Setting::General', default: default, full_name: 'test foo', description: 'test foo', context: :test)
    setting.update(value: setting_value)
    registry.load_values
  end

  describe 'the value getter' do
    context 'with nil default' do
      let(:default) { nil }

      it 'allows nil default value' do
        assert_nil registry['foo']
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
      registry.load_values
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

  describe '#set_user_value' do
    setup do
      registry._add('test',
        category: 'Setting::General',
        default: default,
        type: :integer,
        full_name: 'Test Foo',
        description: 'test update',
        context: :test)
    end

    it 'initiates the DB model if none exists yet' do
      model = registry.set_user_value('test', '10')
      assert_not_nil model
      assert model.valid?
      assert model.save
      assert_equal 10, model.reload.value
    end

    it 'updates the DB model if already exists' do
      model = Setting.create(registry.find('test').attributes.merge(value: setting_value))
      registry.set_user_value('test', '10').save
      assert_equal 10, model.reload.value
    end
  end

  describe '#search_for' do
    it 'can find setting by exact name match' do
      result = registry.search_for('name = foo').to_a
      assert_equal 1, result.size
      assert_equal 'foo', result.first.name
    end

    it 'can find setting by description' do
      result = registry.search_for('test f').to_a
      assert_equal 1, result.size
      assert_equal 'foo', result.first.name
    end
  end
end
