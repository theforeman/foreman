require 'test_helper'

class SettingPresenterTest < ActiveSupport::TestCase
  let(:encrypted) { false }
  let(:initial_value) { nil }
  let(:default) { 2 }
  let(:presenter) do
    SettingPresenter.new({ name: 'presenterfoo',
                           context: :test,
                           category: 'Test',
                           settings_type: 'integer',
                           default: default,
                           full_name: 'test foo',
                           description: 'test foo',
                           value: initial_value,
                           encrypted: encrypted })
  end

  describe '#safe_value' do
    let(:encrypted) { true }
    it 'should hide value if encrypted' do
      assert_equal '*****', presenter.safe_value
    end
  end

  describe '#value' do
    context 'mass assigned nil value' do
      it 'returns default' do
        assert_equal presenter.value, default
      end
    end

    context 'mass assigned non-nil value' do
      let(:initial_value) { 30 }

      it 'returns value' do
        assert_equal presenter.value, initial_value
      end
    end

    context 'set explicit nil value' do
      it 'returns explicitly set nil value' do
        presenter.value = nil
        assert_equal presenter.value, nil
      end
    end

    context 'with global truth defined in SETTINGS' do
      setup { SETTINGS.merge!(presenterfoo: 42) }
      teardown { SETTINGS.delete(:presenterfoo) }

      it 'returns the global' do
        assert_equal 42, presenter.value
      end
    end
  end
end
