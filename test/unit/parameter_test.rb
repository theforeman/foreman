require 'test_helper'

class ParameterTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end
  test  "names may me reused in different parameter groups" do
    p1 = HostParameter.new   :name => "param", :value => "value1", :reference_id => Host.first.id
    assert p1.save
    p2 = DomainParameter.new :name => "param", :value => "value2", :reference_id => Domain.first.id
    assert p2.save
    p3 = CommonParameter.new :name => "param", :value => "value3"
    assert p3.save
    p4 = GroupParameter.new  :name => "param", :value => "value4", :reference_id => Hostgroup.first.id
    assert p4.save
  end

  test "parameters are hierarchically applied" do
    cp = CommonParameter.create :name => "animal", :value => "cat"

    domain = Domain.find_or_create_by_name("company.com")
    hostgroup = Hostgroup.find_or_create_by_name "Common"
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
    :domain => domain , :operatingsystem => Operatingsystem.first, :hostgroup => hostgroup,
    :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    assert_equal "cat", host.host_params["animal"]

    domain.domain_parameters << DomainParameter.create(:name => "animal", :value => "dog")
    host.clear_host_parameters_cache!

    assert_equal "dog", host.host_params["animal"]

    hostgroup.group_parameters << GroupParameter.create(:name => "animal",:value => "cow")
    host.clear_host_parameters_cache!

    assert_equal "cow", host.host_params["animal"]

    host.host_parameters << HostParameter.create(:name => "animal", :value => "pig")
    host.clear_host_parameters_cache!

    assert_equal "pig", host.host_params["animal"]
  end
end
