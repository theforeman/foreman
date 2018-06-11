require 'test_helper'

module Foreman
  class GlobalIdTest < ActiveSupport::TestCase
    test 'encodes an id' do
      assert_equal 'MDE6TW9kZWwtMTIz', Foreman::GlobalId.encode('Model', '123')
    end

    test 'decodes an id' do
      version, type_name, object_value = Foreman::GlobalId.decode('MDE6TW9kZWwtMTIz')
      assert_equal 1, version
      assert_equal 'Model', type_name
      assert_equal '123', object_value
    end
  end
end
