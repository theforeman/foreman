require 'test_helper'

class HostgroupClassTest < ActiveSupport::TestCase

  setup do
    disable_orchestration
    User.current = User.find_by_login "one"
    # puppetclasses(:two) needs to be in production environment
    EnvironmentClass.create(:puppetclass_id => puppetclasses(:two).id, :environment_id => environments(:production).id )
  end

  test 'when creating a new hostgroup class object, an audit entry needs to be added' do
    as_admin do
      assert_difference('Audit.count') do
        HostgroupClass.create! :puppetclass => puppetclasses(:one), :hostgroup => hostgroups(:db)
      end
    end
  end

  test "should update hostgroups_count" do
    pc = puppetclasses(:two)
    assert_difference "pc.hostgroups_count" do
      hc = HostgroupClass.create(:puppetclass_id => pc.id, :hostgroup_id => hostgroups(:common).id)
      pc.reload
    end
  end
end
