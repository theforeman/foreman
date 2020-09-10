require 'test_helper'

class StoredValuesCleanupJobTest < ActiveJob::TestCase
  def setup
    @job = StoredValuesCleanupJob.new
  end

  it 'removes expired stored values and enqueue itself' do
    scope = MiniTest::Mock.new
    scope.expect('destroy_all', nil)
    StoredValue.expects(:expired).with(0).returns(scope)
    @job.perform_now
    assert scope.verify
    assert_enqueued_jobs 1
  end
end
