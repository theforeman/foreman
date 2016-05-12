require 'test_helper'

class CoreExtensionsTest < ActiveSupport::TestCase
  context 'string' do
    test '#to_gb' do
      value = "1024 MB"
      to_gb_value = value.to_gb
      assert_equal(1.0, to_gb_value, "Converted value should be 1.0")
      assert(to_gb_value.is_a?(Float), "Converted value shoud be a float")
    end

    test '#to_gb with iB values' do
      value = "1024 MiB"
      to_gb_value = value.to_gb
      assert_equal(1.0, to_gb_value, "Converted value should be 1.0")
      assert(to_gb_value.is_a?(Float), "Converted value shoud be a float")
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
  end
end
