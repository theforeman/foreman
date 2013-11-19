require 'test_helper'

class ParameterTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end
  test  "names may me reused in different parameter groups" do
    p1 = SystemParameter.new   :name => "param", :value => "value1", :reference_id => System.first.id
    assert p1.save
    p2 = DomainParameter.new :name => "param", :value => "value2", :reference_id => Domain.first.id
    assert p2.save
    p3 = CommonParameter.new :name => "param", :value => "value3"
    assert p3.save
    p4 = GroupParameter.new  :name => "param", :value => "value4", :reference_id => SystemGroup.first.id
    assert p4.save
  end

  test "parameters are hierarchically applied" do
    cp = CommonParameter.create :name => "animal", :value => "cat"

    domain = Domain.find_or_create_by_name("company.com")
    system_group = SystemGroup.find_or_create_by_name "Common"
    system = System.create :name => "myfullsystem", :mac => "aabbecddeeff", :ip => "123.05.02.03",
    :domain => domain , :operatingsystem => Operatingsystem.first, :system_group => system_group,
    :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    assert_equal "cat", system.system_params["animal"]

    domain.domain_parameters << DomainParameter.create(:name => "animal", :value => "dog")
    system.clear_system_parameters_cache!

    assert_equal "dog", system.system_params["animal"]

    system_group.group_parameters << GroupParameter.create(:name => "animal",:value => "cow")
    system.clear_system_parameters_cache!

    assert_equal "cow", system.system_params["animal"]

    system.system_parameters << SystemParameter.create(:name => "animal", :value => "pig")
    system.clear_system_parameters_cache!

    assert_equal "pig", system.system_params["animal"]
  end
end
