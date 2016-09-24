require 'test_helper'

class OrchestrationCommonTest < ActiveSupport::TestCase
  setup do
    class SomeClass
      include Orchestration::Common

      delegate :logger, :to => Rails

      def some_method
        handle_validation_errors do
          raise Net::Validations::Error, 'validation error for SomeClass'
        end
      end
    end
  end

  test "should properly handle validation errors" do
    @instance = SomeClass.new
    assert_nil @instance.some_method
  end
end
