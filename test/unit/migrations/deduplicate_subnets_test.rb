require 'test_helper'

class Migrations::DeduplicateSubnetsTest < ActiveSupport::TestCase
  describe Migrations::DeduplicateSubnets do
    def setup
      @name, @network = 'my-duplicate-subnet', '192.168.42.0'
      @original_subnet = FactoryBot.build(:subnet_ipv4, name: @name, network: @network)
      @duplicate_subnet = FactoryBot.build(:subnet_ipv4, name: @name, network: @network)
      @different_network_subnet = FactoryBot.build(:subnet_ipv4, name: @name, network: '10.0.0.1')
      @different_org_subnet = FactoryBot.build(:subnet_ipv4, name: @name, network: @network).tap do |subnet|
        subnet.organizations = [] # simulate different org assignemnt
      end
      @different_loc_subnet = FactoryBot.build(:subnet_ipv4, name: @name, network: @network).tap do |subnet|
        subnet.locations = [] # simulate different loc assignemnt
      end

      # simulate we already have a network there that would colide
      # with new network names with suffix
      FactoryBot.create(:subnet_ipv4, name: "#{@name}-1", network: @network)

      @subnets = [
        @original_subnet,
        @duplicate_subnet,
        @different_network_subnet,
        @different_org_subnet,
        @different_loc_subnet,
      ]
    end
    it 'deduplicates the subnets with the same name' do
      deduplicator = Migrations::DeduplicateSubnets.new
      result = deduplicator.deduplicate_subnets(@subnets)
      _(result).must_equal [@original_subnet, @different_network_subnet,
                            @different_org_subnet, @different_loc_subnet]
      result.each do |subnet|
        refute subnet.changed? # test we saved the changes
      end
      _(@original_subnet.name).must_equal @name
      _(@different_network_subnet.name).must_equal "#{@name}-2"
      _(@different_org_subnet.name).must_equal "#{@name}-3"
      _(@different_loc_subnet.name).must_equal "#{@name}-4"
    end
  end
end
