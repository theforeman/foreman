require 'test_helper'

class HostBuildStatusTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    stub_smart_proxy_v2_features
    User.current = users(:admin)
    @host = Host.new(:name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03", :ptable => FactoryBot.build(:ptable), :medium => media(:one),
                    :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one),
                    :architecture => architectures(:x86_64), :managed => true,
                    :owner_type => "User", :root_pass => "xybxa6JUkz63w")
    # bypass host.valid?
    HostBuildStatus.any_instance.stubs(:host_status).returns(true)
  end

  let(:host) { @host }
  let(:build) { host.build_status_checker }

  test "should be able to render a template" do
    assert build.errors[:templates].blank?
  end

  test "should fail rendering a template" do
    kind = FactoryBot.create(:template_kind)
    host.update(hostgroup_id: hostgroups(:common).id)
    FactoryBot.create(:provisioning_template, :template => "provision script <%= @foreman.server.status %>",
                                              :name => "My Failed Template",
                                              :template_kind => kind,
                                              :operatingsystem_ids => [host.operatingsystem_id],
                                              :hostgroup_ids => [host.hostgroup_id])
    refute_empty build.errors[:templates]
  end

  test "should be able to ping a smart proxy" do
    assert_empty build.errors[:proxies]
  end
end
