require 'test_helper'

class TopbarSweeperTest < ActiveSupport::TestCase
  def teardown
    TopbarSweeper.controller = nil
  end

  test "controller is thread-local" do
    TopbarSweeper.controller = "main"
    thread_value = nil
    Thread.new { thread_value = TopbarSweeper.controller }.join
    assert_nil thread_value, "Other thread should not see main thread's controller"
    assert_equal "main", TopbarSweeper.controller
  end

  test "expire_cache calls expire_fragment on controller" do
    mock_controller = Minitest::Mock.new
    user = FactoryBot.create(:user)
    mock_controller.expect :expire_fragment, nil, [TopbarSweeper.fragment_name(user.id)]
    TopbarSweeper.controller = mock_controller
    TopbarSweeper.expire_cache(user)
    mock_controller.verify
  end

  test "expire_cache does not raise when controller is nil" do
    TopbarSweeper.controller = nil
    user = FactoryBot.create(:user)
    assert_nothing_raised { TopbarSweeper.expire_cache(user) }
  end
end
