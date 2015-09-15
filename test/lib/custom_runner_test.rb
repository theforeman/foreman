require 'test_helper'

class CustomRunnerTest < ActiveSupport::TestCase
  setup { skip 'Temporarily disabled since Minitest 5 deprecated runner API'}

  test "custom runner is working" do
    # This should always be skipped if the runner is working
    assert false, "Custom runner has failed"
  end
end
