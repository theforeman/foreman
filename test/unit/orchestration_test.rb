require 'test_helper'

class OrchestrationTest < ActiveSupport::TestCase
  def test_host_should_have_queue
    h = Host.new
    assert_respond_to h, :queue
  end
end
