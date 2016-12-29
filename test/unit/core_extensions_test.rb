require 'test_helper'

class CoreExtensionsTest < ActiveSupport::TestCase
  context 'string' do
    test '#to_gb' do
      value = "1024 MB"
      to_gb_value = value.to_gb
      assert_equal(1.0, to_gb_value, "Converted value should be 1.0")
      assert(to_gb_value.is_a?(Float), "Converted value shoud be a float")
    end

    test '#to_gb with no units' do
      value = '10.50'
      assert_equal 10.5, value.to_gb.gigabytes, 'Converted value should be 10.5 bytes'
    end

    test '#to_gb for bytes' do
      value = '0 Bytes'
      to_gb_value = value.to_gb
      assert_equal 0.0, to_gb_value, 'Converted values should be 0'
    end

    test '#to_gb with iB values' do
      value = "1024 MiB"
      to_gb_value = value.to_gb
      assert_equal(1.0, to_gb_value, "Converted value should be 1.0")
      assert(to_gb_value.is_a?(Float), "Converted value shoud be a float")
    end

    test '#to_gb non matching string raises exception with correct message' do
      value = '1 something that is not matched'
      exception = assert_raises(RuntimeError) { value.to_gb }
      assert exception.message =~ /^Unknown string/, "wrong exception reason #{exception}"
    end

    test '#to_utf8' do
      number = 100
      assert_raises(NoMethodError) do
        number.to_utf8
      end
      string = "string"
      string.expects(:encode).with('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
      string.to_utf8
    end

    test "should detect erb" do
      assert '<% object_id %>'.contains_erb?
      assert '<%= object_id %>'.contains_erb?
      assert '[<% object_id %>, <% self %>]'.contains_erb?
      refute '[1,2,3]'.contains_erb?
      refute '{a: "b"}'.contains_erb?
      refute 'plain value'.contains_erb?
    end
  end
end
