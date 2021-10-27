require 'test_helper'

class SettingPresenterTest < ActiveSupport::TestCase
  let(:encrypted) { false }
  let(:presenter) do
    SettingPresenter.new({ name: 'presenterfoo',
                           context: :test,
                           category: 'Test',
                           settings_type: 'integer',
                           default: 2,
                           full_name: 'test foo',
                           description: 'test foo',
                           encrypted: encrypted })
  end

  describe '#safe_value' do
    let(:encrypted) { true }
    it 'should hide value if encrypted' do
      assert_equal '*****', presenter.safe_value
    end
  end

  describe '#value' do
    context 'with global truth defined in SETTINGS' do
      setup { SETTINGS.merge!(presenterfoo: 42) }
      teardown { SETTINGS.delete(:presenterfoo) }

      it 'returns the global' do
        assert_equal 42, presenter.value
      end
    end
  end
end
