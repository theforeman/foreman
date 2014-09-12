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
  test "should return config_template names using method #config_template_names" do
    env = environments(:production)
    assert_equal 3, env.config_template_ids.count
    assert_equal 3, env.config_template_names.count
    assert_equal ["MyFinish", "MyString", "MyString2"], env.config_template_names.sort
  end

  test "should add config_template association by passing array of names" do
    env = environments(:production)
    assert_difference('env.config_template_names.count') do
      env.config_template_names = ["MyFinish", "MyString", "MyString2", "PXELinux global default"]
    end
    assert_equal 4, env.config_template_ids.count
    assert_equal 4, env.config_template_names.count
    assert_equal ["MyFinish", "MyString", "MyString2", "PXELinux global default"], env.config_template_names.sort
  end

  test "should delete config_template association by passing array of names" do
    env = environments(:production)
    assert_difference('env.config_template_names.count', -1) do
      env.config_template_names = ["MyFinish", "MyString"]
    end
    assert_equal 2, env.config_template_ids.count
    assert_equal 2, env.config_template_names.count
    assert_equal ["MyFinish", "MyString"], env.config_template_names.sort
  end

  # Test non-default AR extension *_names where method is :label for has_many :hostgroups
  test "should return hostgroup labels (not names) using method #hostgroup_names" do
    env = environments(:production)
    assert_equal 3, env.hostgroup_ids.count
    assert_equal 3, env.hostgroup_names.count
    assert_equal ["Common", "Parent/inherited", "db"], env.hostgroup_names.sort
  end


  ### belongs_to ###
  #
  # Test default AR extenstion *_name where method is :name by default
  test "should return domain name using method #domain_name" do
    host = Factory.create(:host, :domain => FactoryGirl.create(:domain, :name => "common.net"))
    assert_equal "common.net", host.domain_name
  end

  test "should update domain_id by passing existing domain name" do
    host = Factory.create(:host, :domain => FactoryGirl.create(:domain, :name => "common.net"))
    orig_id = host.domain_id
    host.domain_name = "yourdomain.net"
    host.save!
    new_id = host.domain_id
    refute_equal orig_id, new_id
  end

  # Test non-default AR extenstion *_nam where method is :label for belongs_to :hostgroup
  test "should return hostgroup label using method #hostgroup_name" do
    host = Factory.create(:host)
    host.update_attribute(:hostgroup, hostgroups(:inherited))
    assert_equal "Parent/inherited", host.hostgroup_name
  end

  test "should update hostgroup_id by passing existing hostgroup label" do
    host = Factory.create(:host)
    orig_id = host.hostgroup_id
    host.hostgroup_name = "Parent/inherited"
    host.save!
    new_id = host.hostgroup_id
    refute_equal orig_id, new_id
  end


end
