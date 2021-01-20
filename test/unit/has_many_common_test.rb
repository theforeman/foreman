require 'test_helper'

class HasManyCommonTest < ActiveSupport::TestCase
  # All AR classes include HasManyCommon

  setup do
    User.current = users :admin
    disable_orchestration
  end

  ### has_many ###
  #
  # Test default AR extenstion *_names where method is :name by default
  test "should return provisioning_template names using method #provisioning_template_names" do
    hg = hostgroups(:common)
    assert_equal 4, hg.provisioning_template_ids.count
    assert_equal 4, hg.provisioning_template_names.count
    assert_equal ["MyFinish", "MyScript", "MyString", "MyString2"], hg.provisioning_template_names.sort
  end

  test "should add provisioning_template association by passing array of names" do
    hg = hostgroups(:common)
    assert_difference(-> { hg.provisioning_template_names.count }, 1) do
      hg.provisioning_template_names = ["MyFinish", "MyScript", "MyString", "MyString2", "PXELinux global default"]
    end
    assert_equal 5, hg.provisioning_template_ids.count
    assert_equal 5, hg.provisioning_template_names.count
    assert_equal ["MyFinish", "MyScript", "MyString", "MyString2", "PXELinux global default"], hg.provisioning_template_names.sort
  end

  test "should delete provisioning_template association by passing array of names" do
    hg = hostgroups(:common)
    assert_difference(-> { hg.provisioning_template_names.count }, -1) do
      hg.provisioning_template_names = ["MyFinish", "MyScript", "MyString"]
    end
    assert_equal 3, hg.provisioning_template_ids.count
    assert_equal 3, hg.provisioning_template_names.count
    assert_equal ["MyFinish", "MyScript", "MyString"], hg.provisioning_template_names.sort
  end

  # Test non-default AR extension *_names where method is :label for has_many :hostgroups
  test "should return hostgroup labels (not names) using method #hostgroup_names" do
    templ = templates(:mystring2)
    assert_equal 2, templ.hostgroup_ids.count
    assert_equal 2, templ.hostgroup_names.count
    assert_equal ["Common", "Parent/inherited"], templ.hostgroup_names.sort
  end

  ### belongs_to ###
  #
  # Test default AR extenstion *_name where method is :name by default
  test "should return domain name using method #domain_name" do
    host = FactoryBot.build_stubbed(:host, :domain => FactoryBot.build(:domain, :name => "common.net"))
    assert_equal "common.net", host.domain_name
  end

  test "should update domain_id by passing existing domain name" do
    host = FactoryBot.build(:host, :domain => FactoryBot.build(:domain, :name => "common.net"))
    orig_id = host.domain_id
    host.domain_name = "yourdomain.net"
    host.save!
    new_id = host.domain_id
    refute_equal orig_id, new_id
  end

  # Test non-default AR extenstion *_nam where method is :label for belongs_to :hostgroup
  test "should return hostgroup label using method #hostgroup_name" do
    host = FactoryBot.build(:host)
    host.update_attribute(:hostgroup, hostgroups(:inherited))
    assert_equal "Parent/inherited", host.hostgroup_name
  end

  test "should update hostgroup_id by passing existing hostgroup label" do
    host = FactoryBot.build(:host)
    orig_id = host.hostgroup_id
    host.hostgroup_name = "Parent/inherited"
    host.hostgroup.subnet.locations = [host.location]
    host.hostgroup.subnet.organizations = [host.organization]
    host.hostgroup.subnet6.locations = [host.location]
    host.hostgroup.subnet6.organizations = [host.organization]
    host.save!
    new_id = host.hostgroup_id
    refute_equal orig_id, new_id
  end

  test "should raise not found error if hostgroup name does not exist" do
    host = FactoryBot.build_stubbed(:host)
    assert_raise Foreman::AssociationNotFound do
      host.hostgroup_name = "No such HG"
    end
  end

  ## Test name methods resolve for Plugin AR objects
  class ::FakePlugin; end
  class ::FakePlugin::FakeModel; end

  test "should return plugin associations" do
    Host::Managed.class_eval do
      belongs_to :fake_model, :class_name => '::FakePlugin::FakeModel'
    end
    assert_equal FactoryBot.build_stubbed(:host).assoc_klass(:fake_model), FakePlugin::FakeModel
  end
end
