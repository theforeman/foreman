require 'test_helper'

class AdvisoryLockManagerTest < ActiveSupport::TestCase
  test "transaction lock" do
    ::Foreman::AdvisoryLockManager.with_transaction_lock("test_lock") do
      # just perform a dummy select for a fixture
      assert Setting.unscoped.count > 0
    end
  end

  test "transaction lock" do
    ::Foreman::AdvisoryLockManager.with_session_lock("test_tx_lock") do
      # just perform a dummy select for a fixture
      assert Setting.unscoped.count > 0
    end
  end
end
