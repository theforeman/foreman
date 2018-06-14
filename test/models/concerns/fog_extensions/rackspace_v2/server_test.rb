require 'test_helper'

class RackspaceV2ServerTest < ActiveSupport::TestCase
  setup { Fog.mock! }
  teardown { Fog.unmock! }

  let(:server) { Fog::Compute::RackspaceV2::Server.new }

  test "#ip_addresses returns all IPs" do
    server.expects(:addresses).at_least_once.returns(
      {
        "public" => [
          {"version" => 4, "addr" => "166.78.105.63"},
          {"version" => 6, "addr" => "2001:4801:7817:0072:0fe1:75e8:ff10:61a9"}
        ],
        "private" => [{"version" => 4, "addr" => "10.177.18.209"}]
      }
    )
    assert_equal ["10.177.18.209", "166.78.105.63", "2001:4801:7817:0072:0fe1:75e8:ff10:61a9"], server.ip_addresses.sort
  end
end
