require 'test_helper'

class HostgroupClassTest < ActiveSupport::TestCase
  test 'when creating a new hostgroup class object, an audit entry needs to be added' do
    as_admin do
      assert_difference('Audit.count') do
        HostgroupClass.create! :puppetclass => puppetclasses(:one), :hostgroup => hostgroups(:db)
      end
    end
  end
end
