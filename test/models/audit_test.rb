require 'test_helper'

class AuditTest < ActiveSupport::TestCase
  test 'can be found by provisioning template name' do
    template = FactoryGirl.create(:provisioning_template)
    template.update :template => 'new content'
    audits = Audit.search_for "provisioning_template = #{template.name}"
    assert_not_nil audits.select { |a| a.action.to_s == 'update' && a.audited_changes['template'].last == 'new content' }
  end

  test 'does not find any unrelated audits' do
    template = FactoryGirl.create(:provisioning_template)
    template.update :template => 'new content'
    audits = Audit.search_for "provisioning_template = does not exist"
    assert_empty audits
  end

  test 'can be found by partition table name' do
    template = FactoryGirl.create(:ptable, :os_family => nil)
    template.update :template => 'new content'
    audits = Audit.search_for "partition_table = #{template.name}"
    assert_not_nil audits.select { |a| a.action.to_s == 'update' && a.audited_changes['template'].last == 'new content' }
  end
end
