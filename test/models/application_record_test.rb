require 'test_helper'

class ApplicationRecordTest < ActiveSupport::TestCase
  describe '<=>' do
    test 'return -1 when self is smaller than other' do
      assert_equal(-1, (Host.new(name: 'aaa') <=> Host.new(name: 'zzz')))
    end

    test 'return 0 when self is equal to other' do
      assert_equal 0, (Host.new(name: 'name') <=> Host.new(name: 'name'))
    end

    test 'return 1 when self is bigger than other' do
      assert_equal 1, (Host.new(name: 'zzz') <=> Host.new(name: 'aaa'))
    end

    test 'return nil when could not be compared' do
      assert_nil (Token.new <=> Host.new)
    end
  end
end
