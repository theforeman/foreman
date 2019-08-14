require 'test_helper'

class AwsServerTest < ActiveSupport::TestCase
  setup { Fog.mock! }
  teardown { Fog.unmock! }

  let(:server) { Fog::AWS::Compute::Server.new }
  let(:instance_id) { "i-#{Fog::Mock.random_hex(8)}" }

  test "#to_s and #name return name from tags" do
    server.expects(:tags).at_least_once.returns(
      {
        'Name' => 'test.example.com',
      }
    )
    assert_equal 'test.example.com', server.to_s
    assert_equal 'test.example.com', server.name
  end

  test "#to_s and #name return name from instance_id" do
    server.expects(:id).at_least_once.returns(instance_id)
    server.expects(:tags).at_least_once.returns({})
    assert_equal instance_id, server.to_s
    assert_equal instance_id, server.name
  end
end
