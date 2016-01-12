require 'test_helper'

class CustomRunnerTest < ActiveSupport::TestCase
  test "custom runner is working" do
    # This should always be skipped if the runner is working
    assert false, "Custom runner has failed"
  end
end
