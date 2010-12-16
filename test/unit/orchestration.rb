require 'test_helper'

class OrchestrationTest < ActiveSupport::TestCase
  def test_host_should_have_queue
    h = Host.new
    assert_respond_to h, :queue
  end

  def test_action_queue_should_be_an_array
    assert_kind_of Array, Host.get_external_actions
  end
end
