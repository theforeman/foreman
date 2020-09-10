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

    test 'raises an exception when decoding an invalid id' do
      assert_raises ::Foreman::GlobalId::InvalidGlobalIdException do
        Foreman::GlobalId.decode('12')
      end
    end

    describe '.for' do
      test 'generates id for object' do
        model = FactoryBot.create(:model)
        assert_equal Foreman::GlobalId.encode('Model', model.id), Foreman::GlobalId.for(model)
      end

      test 'generates id for Redhat OS' do
        os = FactoryBot.create(:rhel7_5)
        assert_equal Foreman::GlobalId.encode('Operatingsystem', os.id), Foreman::GlobalId.for(os)
      end
    end
  end
end
