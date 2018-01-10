require 'test_helper'

class AuditExtensionsTest < ActiveSupport::TestCase
  def setup
    @user = users :admin
  end

  test "should be connected to current user" do
    audit = as_admin do
      FactoryBot.create(:audit)
    end

    assert_equal audit.user_id, @user.id
    assert_equal audit.username, @user.name
  end

  test "host scoped search for audit works" do
    resource = FactoryBot.create(:host, :managed, :with_auditing)
    assert Audit.search_for("host = #{resource.name}").count > 0
  end

  test "host autocomplete works in audit search" do
    FactoryBot.create(:host, :managed)
    hosts = Audit.complete_for("host = ", {:controller => 'audits'})
    assert hosts.count > 0
  end

  test "audit's change is filtered when data is encrypted" do
    setting = settings(:attributes63)
    setting.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    setting.value = '654321'
    as_admin do
      assert setting.save
    end
    a = Audit.where(auditable_type: 'Setting')
    assert_equal "[redacted]", a.last.audited_changes["value"][1]
  end

  test "search for type=lookupvalue in audit" do
    key = lookup_keys(:three)
    FactoryBot.create :lookup_value, :with_auditing, :lookup_key_id => key.id, :value => false, :match => "hostgroup=Common"
    refute_empty Audit.search_for("type = override_value")
  end

  test "search for type=compute_resource in audit" do
    FactoryBot.create(:ec2_cr, :with_auditing)
    refute_empty Audit.search_for("type = compute_resource")
  end

  test "audited changes field can be greater then 65K bytes" do
    prov_template = templates(:mystring)
    prov_template.template = "0000000000" * 3500
    as_admin do
      assert prov_template.save!
      prov_template.template = "1111111111" * 3500
      assert prov_template.save!
    end
    assert Audit.last.audited_changes.to_s.bytesize > 66000
  end
end
