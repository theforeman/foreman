require 'test_helper'

class AuditExtensionsTest < ActiveSupport::TestCase
  def setup
    @user = users :admin
  end

  test "should be connected to current user" do
    audit = as_admin do
      FactoryGirl.create(:audit)
    end

    assert_equal audit.user_id, @user.id
    assert_equal audit.username, @user.name
  end

  test "host scoped search for audit works" do
    resource = FactoryGirl.create(:host, :managed)
    assert Audit.search_for("host = #{resource.name}").count > 0
  end

  test "host autocomplete works in audit search" do
    FactoryGirl.create(:host, :managed)
    hosts = Audit.complete_for("host = ", {:controller => 'audits'})
    assert hosts.count > 0
  end
end
