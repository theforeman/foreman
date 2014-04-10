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

end
