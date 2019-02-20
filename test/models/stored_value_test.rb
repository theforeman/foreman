require 'test_helper'

class StoredValueTest < ActiveSupport::TestCase
  let(:stored_value) { FactoryBot.create(:stored_value) }

  before do
    stored_value
  end

  describe 'scope ->valid' do
    it 'do not return expired' do
      FactoryBot.create(:stored_value, expire_at: Time.now - 1.hour)

      assert_equal 1, StoredValue.valid.count
      assert_equal stored_value.id, StoredValue.valid.first.id
    end

    it 'returns permanent values' do
      permanent_value = FactoryBot.create(:stored_value, expire_at: nil)

      assert_equal 2, StoredValue.valid.count
      assert_includes StoredValue.valid, permanent_value
    end
  end

  describe '.write' do
    it 'handles zero bytes' do
      assert StoredValue.write('UNIQUE-KEY', "Hell\x00world")
      assert_equal StoredValue.read('UNIQUE-KEY'), "Hell\x00world"
    end
  end
end
