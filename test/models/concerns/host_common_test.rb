require 'test_helper'

class HostCommonTest < ActiveSupport::TestCase
  test 'grub passwords are not limited to 255 characters' do
    assert_nil Host::Managed.columns_hash['grub_pass'].limit
    assert_nil Hostgroup.columns_hash['grub_pass'].limit
  end
end
