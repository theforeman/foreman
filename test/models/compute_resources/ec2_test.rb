require 'test_helper'
require 'models/compute_resources/compute_resource_test_helpers'

module Foreman
  module Model
    class EC2Test < ActiveSupport::TestCase
      include ComputeResourceTestHelpers

      should_not validate_presence_of(:url)

      should have_one(:key_pair).with_foreign_key('compute_resource_id').
        dependent(:destroy)

      test "#associated_host matches any NIC" do
        host = FactoryBot.create(:host, :ip => '10.0.0.154')
        cr = FactoryBot.build_stubbed(:ec2_cr)
        iface = mock('iface1', :public_ip_address => '10.0.0.154', :private_ip_address => "10.1.1.1")
        assert_equal host, as_admin { cr.associated_host(iface) }
      end

      describe "find_vm_by_uuid" do
        it "raises RecordNotFound when the vm does not exist" do
          cr = mock_cr_servers(Foreman::Model::EC2.new, empty_servers)
          assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
        end

        it "raises RecordNotFound when the compute raises EC2 error" do
          cr = mock_cr_servers(Foreman::Model::EC2.new, servers_raising_exception(Fog::AWS::Compute::Error))
          assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
        end
      end

      context "key pairs" do
        test "should be capable of key_pair" do
          cr = FactoryBot.create(:ec2_cr)
          assert_includes(cr.capabilities, :key_pair)
        end
      end

      describe '#normalize_vm_attrs' do
        let(:base_cr) { FactoryBot.build(:ec2_cr) }
        let(:cr) do
          mock_cr(base_cr,
            :subnets => [
              stub(:subnet_id => 'sn1', :cidr_block => 'cidr blk 1'),
              stub(:subnet_id => 'sn2', :cidr_block => 'cidr blk 2'),
            ],
            :security_groups => [
              stub(:group_id => 'grp1', :name => 'group 1'),
              stub(:group_id => 'grp2', :name => 'group 2'),
            ],
            :flavors => [
              stub(:id => 'flvr1', :name => 'flavour 1'),
              stub(:id => 'flvr2', :name => 'flavour 2'),
            ]
          )
        end

        test 'nilifies blank flavor_id' do
          assert_blank_attr_nilified(cr, 'flavor_id')
        end

        test 'sets flavor_name' do
          vm_attrs = {
            'flavor_id' => 'flvr1',
          }
          normalized = cr.normalize_vm_attrs(vm_attrs)

          assert_equal('flavour 1', normalized['flavor_name'])
        end

        test 'nilifies blank availability_zone' do
          assert_blank_attr_nilified(cr, 'availability_zone')
        end

        test 'nilifies blank subnet_id' do
          assert_blank_attr_nilified(cr, 'subnet_id')
        end

        test 'sets subnet_name' do
          vm_attrs = {
            'subnet_id' => 'sn1',
          }
          normalized = cr.normalize_vm_attrs(vm_attrs)

          assert_equal('cidr blk 1', normalized['subnet_name'])
        end

        describe 'images' do
          let(:base_cr) { FactoryBot.create(:ec2_cr, :with_images) }

          test 'sets image_name' do
            vm_attrs = {
              'image_id' => cr.images.last.uuid,
            }
            normalized = cr.normalize_vm_attrs(vm_attrs)

            assert_equal(cr.images.last.name, normalized['image_name'])
          end
        end

        test 'maps security_groups' do
          vm_attrs = {
            'security_group_ids' => ['', 'grp1'],
          }
          expected_attrs = {
            '0' => {
              'id' => 'grp1',
              'name' => 'group 1',
            },
          }
          normalized = cr.normalize_vm_attrs(vm_attrs)

          assert_equal(expected_attrs, normalized['security_groups'])
        end

        test 'correctly fills empty attributes' do
          normalized = cr.normalize_vm_attrs({})
          expected_attrs = {
            'flavor_id' => nil,
            'flavor_name' => nil,
            'image_id' => nil,
            'image_name' => nil,
            'availability_zone' => nil,
            'managed_ip' => nil,
            'subnet_id' => nil,
            'subnet_name' => nil,
            'security_groups' => {},
          }

          assert_equal(expected_attrs.keys.sort, normalized.keys.sort)
          assert_equal(expected_attrs, normalized)
        end

        test 'attribute names' do
          check_vm_attribute_names(cr)
        end
      end

      test "url is nil without specifying govcloud" do
        ec2 = Foreman::Model::EC2.new
        assert_nil ec2.region
        assert_nil ec2.url
      end

      test "setting govcloud virtual attribute to 1, region is set to gov cloud" do
        ec2 = Foreman::Model::EC2.new(:gov_cloud => '1')
        assert_equal Foreman::Model::EC2::GOV_CLOUD_REGION, ec2.region
        assert_equal ec2.region, ec2.url
      end

      test "setting govcloud virtual attribute to non 1 value, gov cloud region remains untouched" do
        ec2 = Foreman::Model::EC2.new(:gov_cloud => '0')
        assert_nil ec2.region
        assert_nil ec2.url

        ec2 = Foreman::Model::EC2.new(:region => 'eu-west-1', :gov_cloud => '0')
        assert_equal 'eu-west-1', ec2.region
        assert_equal ec2.region, ec2.url
      end
    end
  end
end
