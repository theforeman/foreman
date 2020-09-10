require 'test_helper'

class HostBuildStatusTest < ActiveSupport::TestCase
  attr_reader :build

  setup do
    disable_orchestration
    stub_smart_proxy_v2_features
    User.current = users(:admin)
    @host = Host.new(:name => "myfullhost", :mac => "aabbecddeeff", :ip => "2.3.4.03", :ptable => FactoryBot.build(:ptable), :medium => media(:one),
                    :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:one), :puppet_proxy => smart_proxies(:puppetmaster),
                    :architecture => architectures(:x86_64), :environment => environments(:production), :managed => true,
                    :owner_type => "User", :root_pass => "xybxa6JUkz63w")
    @build = @host.build_status_checker
    # bypass host.valid?
    HostBuildStatus.any_instance.stubs(:host_status).returns(true)
  end

  test "should be able to render a template" do
    build.check_all_statuses
    assert build.errors[:templates].blank?
  end

  test "should fail rendering a template" do
    host = @host
    kind = FactoryBot.create(:template_kind)
    FactoryBot.create(:provisioning_template, :template => "provision script <%= @foreman.server.status %>", :name => "My Failed Template", :template_kind => kind, :operatingsystem_ids => [host.operatingsystem_id], :environment_ids => [host.environment_id], :hostgroup_ids => [host.hostgroup_id])
    @build = host.build_status_checker
    refute_empty @build.errors[:templates]
  end

  test "should be able to ping a smart proxy" do
    build.check_all_statuses
    assert_empty build.errors[:proxies]
  end
end
