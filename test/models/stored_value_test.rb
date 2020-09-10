require 'test_helper'

class StoredValueTest < ActiveSupport::TestCase
  let(:stored_value) { FactoryBot.create(:stored_value) }
  let(:expired) { FactoryBot.create(:stored_value, expire_at: Time.now - 1.hour) }

  before do
    stored_value
    expired
  end

  describe 'scope ->valid' do
    it 'do not return expired' do
      assert_equal 1, StoredValue.valid.count
      refute_includes StoredValue.valid, expired
    end

    it 'returns permanent values' do
      permanent_value = FactoryBot.create(:stored_value, expire_at: nil)

      assert_equal 2, StoredValue.valid.count
      assert_includes StoredValue.valid, permanent_value
    end
  end

  describe 'scope ->expired' do
    it 'does not return valid' do
      assert_equal 1, StoredValue.expired.count
      refute_includes StoredValue.expired, stored_value
    end

    it 'does not return permanent values' do
      permanent_value = FactoryBot.create(:stored_value, expire_at: nil)

      assert_equal 1, StoredValue.expired.count
      refute_includes StoredValue.expired, permanent_value
    end

    it 'considers expired only expired ago given time' do
      assert_equal 0, StoredValue.expired(2.hours).count
      refute_includes StoredValue.expired(2.hours), expired
    end
  end

  describe '.write' do
    it 'handles zero bytes' do
      assert StoredValue.write('UNIQUE-KEY', "Hell\x00world")
      assert_equal StoredValue.read('UNIQUE-KEY'), "Hell\x00world"
    end

    it 'handles special characters' do
      assert StoredValue.write('UNIQUE-KEY', "šeď^světa")
      assert_equal StoredValue.read('UNIQUE-KEY'), "šeď^světa"
    end

    it 'handles special characters in json' do
      assert StoredValue.write('UNIQUE-KEY', '{ "name": "šeď^světa" }')
      assert_equal StoredValue.read('UNIQUE-KEY').to_json, '{ "name": "šeď^světa" }'.to_json
    end
  end
end
