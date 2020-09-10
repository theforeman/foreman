require 'test_helper'

class AuditSearchTest < ActiveSupport::TestCase
  def setup
    @user = users :admin
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

  test "search for type=lookupvalue in audit" do
    FactoryBot.create :lookup_value, :with_auditing, :value => false, :match => "hostgroup=Common"
    refute_empty Audit.search_for("type = override_value")
  end

  test "search for type=compute_resource in audit" do
    FactoryBot.create(:ec2_cr, :with_auditing)
    refute_empty Audit.search_for("type = compute_resource")
  end

  test "search for type=subnet in audit" do
    FactoryBot.create(:subnet_ipv4, :with_auditing)
    refute_empty Audit.search_for("type = subnet")
  end
end
