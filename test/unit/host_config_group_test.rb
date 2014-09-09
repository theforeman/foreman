require 'test_helper'

class HostConfigGroupTest < ActiveSupport::TestCase

  test 'relationship host.group_puppetclasses' do
    host = hosts(:one)
    assert_equal 4, host.group_puppetclasses.count
    assert_equal ['auth', 'chkmk', "nagios", 'pam'].sort, host.group_puppetclasses.pluck(:name).sort
  end

  test 'relationship host.config_groups ' do
    host = hosts(:one)
    assert_equal 2, host.config_groups.count
    assert_equal ['Monitoring', 'Security'].sort, host.config_groups.pluck(:name).sort
  end

  test 'relationship hostgroup.group_puppetclasses' do
    hostgroup = hostgroups(:common)
    assert_equal 4, hostgroup.group_puppetclasses.count
    assert_equal ['chkmk', "nagios", 'git', 'vim'].sort, hostgroup.group_puppetclasses.pluck(:name).sort
  end

  test 'relationship hostgroup.config_groups' do
    hostgroup = hostgroups(:common)
    assert_equal 2, hostgroup.config_groups.count
    assert_equal ['Monitoring','Tools'].sort, hostgroup.config_groups.pluck(:name).sort
  end

  context "host and hostgroup both have id=1" do
    setup do
      @host = FactoryGirl.create(:host)
      @hostgroup = FactoryGirl.create(:hostgroup)
      @host.update_attribute(:id, 1)
      @hostgroup.update_attribute(:id, 1)
      @config_group = FactoryGirl.create(:config_group)
    end

    it 'validation error if same config group is added to host more than once' do
      assert_difference('HostConfigGroup.count') do
        @host.config_groups << @config_group
      end
      assert_difference('HostConfigGroup.count', 0) do
        assert_raise ActiveRecord::RecordInvalid do
          @host.config_groups << @config_group
        end
      end
    end

    it 'no validation error if config groups has hostgroup and host with same id' do
      assert_equal @host.id, @hostgroup.id
      assert_difference('HostConfigGroup.count') do
        @host.config_groups << @config_group
      end
      assert_difference('HostConfigGroup.count') do
        @hostgroup.config_groups << @config_group
      end
    end
  end
end
