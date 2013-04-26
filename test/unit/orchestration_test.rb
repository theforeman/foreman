require 'test_helper'

class OrchestrationTest < ActiveSupport::TestCase
  def test_host_should_have_queue
    h = Host.new
    assert_respond_to h, :queue
  end

  test "test host can call protected queue methods" do
    class Host::Test < Host::Base
      include Orchestration
      def test_execute(method)
        execute({:action => [self, method]})
      end
      protected
      def setTest ; true ; end
    end
    h = Host::Test.new
    assert h.test_execute(:setTest)
    assert_raise Foreman::Exception do
      h.test_execute(:noSuchTest)
    end
  end

end
