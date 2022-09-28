require 'test_helper'

class HostPowerStatusResolverTest < ActiveSupport::TestCase
  let(:context) { { current_user: User.current } }
  let(:host) { FactoryBot.create(:host, compute_resource: FactoryBot.create(:vmware_cr)) }
  let(:resolver) { Resolvers::Host::PowerStatus.new(object: host, context: context, field: nil) }

  setup { Fog.mock! }
  teardown { Fog.unmock! }

  test 'show power status for a host' do
    expected_resp = {
      :id => host.id,
      :state => "on",
      :title => "On",
    }
    Host.any_instance.stubs(:supports_power?).returns(true)
    Host.any_instance.stubs(:supports_power_and_running?).returns(true)
    assert_equal(expected_resp.sort, resolver.resolve.sort)
  end
end
