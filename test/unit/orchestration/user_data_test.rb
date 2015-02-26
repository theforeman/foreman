require 'test_helper'

class ComputeOrchestrationTest < ActiveSupport::TestCase
  test "a helpful error message shows up if no user_data is provided and it's necessary" do
    image = images(:one)
    host = FactoryGirl.build(:host, :operatingsystem => image.operatingsystem, :image => image,
                                    :compute_resource => image.compute_resource)
    host.send(:setUserData)
    assert host.errors.full_messages.first =~ /associate it/
  end
end
