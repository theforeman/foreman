require 'test_helper'

class OrchestrationTest < ActiveSupport::TestCase
  def test_system_should_have_queue
    h = System.new
    assert_respond_to h, :queue
  end

  test "test system can call protected queue methods" do
    class System::Test < System::Base
      include Orchestration
      def test_execute(method)
        execute({:action => [self, method]})
      end
      protected
      def setTest ; true ; end
    end
    h = System::Test.new
    assert h.test_execute(:setTest)
    assert_raise Foreman::Exception do
      h.test_execute(:noSuchTest)
    end
  end

end
