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

  context 'audit search for hosts' do
    setup do
      @resource = FactoryGirl.create(:host, :managed)
      Organization.current = @resource.organization
      Location.current = @resource.location
    end

    test "host scoped search for audit works" do
      assert Audit.search_for("host = #{@resource.name}").count > 0
    end

    test "host autocomplete works in audit search" do
      hosts = Audit.complete_for("host = ", {:controller => 'audits'})
      assert hosts.count > 0
    end
  end

  test "audit's change is filtered when data is encrypted" do
    setting = settings(:attributes63)
    setting.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    setting.value = '654321'
    as_admin do
      assert setting.save
    end
    a = Audit.where(auditable_type: 'Setting')
    assert_equal "[encrypted]", a.last.audited_changes["value"][1]
  end
end
