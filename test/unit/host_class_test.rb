require 'test_helper'

class HostClassTest < ActiveSupport::TestCase

  setup do
    disable_orchestration
    User.current = User.find_by_login "one"
    # puppetclasses(:two) needs to be in production environment
    EnvironmentClass.create(:puppetclass_id => puppetclasses(:two).id, :environment_id => environments(:production).id )
  end

  test "should update hosts_count" do
    pc = puppetclasses(:two)
    assert_difference "pc.hosts_count" do
      hc = HostClass.create(:puppetclass_id => pc.id, :host_id => FactoryGirl.create(:host).id)
      pc.reload
    end
  end
end
