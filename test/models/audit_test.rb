require 'test_helper'

class AuditTest < ActiveSupport::TestCase
  test 'can be found by provisioning template name' do
    template = FactoryBot.create(:provisioning_template)
    template.update :template => 'new content'
    audits = Audit.search_for "provisioning_template = #{template.name}"
    assert_not_nil audits.select { |a| a.action.to_s == 'update' && a.audited_changes['template'].last == 'new content' }
  end

  test 'does not find any unrelated audits' do
    template = FactoryBot.create(:provisioning_template)
    template.update :template => 'new content'
    audits = Audit.search_for "provisioning_template = does not exist"
    assert_empty audits
  end

  test 'can be found by partition table name' do
    template = FactoryBot.create(:ptable, :os_family => nil)
    template.update :template => 'new content'
    audits = Audit.search_for "partition_table = #{template.name}"
    assert_not_nil audits.select { |a| a.action.to_s == 'update' && a.audited_changes['template'].last == 'new content' }
  end

  test 'can be found by setting name' do
    FactoryBot.create(:setting, name: 'test_audit_setting')
    Setting.find_by(name: 'test_audit_setting').update(value: 'New value')
    audits = Audit.search_for('setting = test_audit_setting')
    assert_not_nil audits.select { |a| a.action.to_s == 'update' && a.audited_changes['auditable_name'] == 'test_audit_setting' }
  end

  describe 'audited nics' do
    let(:host) { FactoryBot.create(:host, :managed, :with_auditing) }
    let(:nic) { host.primary_interface }

    test 'can be found by ip' do
      nic
      audit = Audit.search_for("interface_ip = #{nic.ip}").first
      assert_equal nic.type, audit.auditable_type
      assert_equal 'create', audit.action
    end

    test 'can be found by name' do
      nic
      audit = Audit.search_for("interface_fqdn = #{nic.name}").first
      assert_equal nic.type, audit.auditable_type
      assert_equal 'create', audit.action
    end

    test 'can be found by mac' do
      nic
      audit = Audit.search_for("interface_mac = #{nic.mac}").first
      assert_equal nic.type, audit.auditable_type
      assert_equal 'create', audit.action
    end
  end
end
