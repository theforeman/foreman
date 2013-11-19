require 'test_helper'

class HasManyCommonTest < ActiveSupport::TestCase

  # All AR classes include HasManyCommon

  setup do
    User.current = User.find_by_login "admin"
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
      env.config_template_names = ["MyFinish", "MyString", "MyString2", "PXE Default File"]
    end
    assert_equal 4, env.config_template_ids.count
    assert_equal 4, env.config_template_names.count
    assert_equal ["MyFinish", "MyString", "MyString2", "PXE Default File"], env.config_template_names.sort
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

  # Test non-default AR extension *_names where method is :label for has_many :system_groups
  test "should return system_group labels (not names) using method #system_group_names" do
    env = environments(:production)
    assert_equal 3, env.system_group_ids.count
    assert_equal 3, env.system_group_names.count
    assert_equal ["Common", "Parent/inherited", "db"], env.system_group_names.sort
  end


  ### belongs_to ###
  #
  # Test default AR extenstion *_name where method is :name by default
  test "should return domain name using method #domain_name" do
    system = systems(:one)
    assert_equal "mydomain.net", system.domain_name
  end

  test "should update domain_id by passing existing domain name" do
    system = systems(:one)
    orig_id = system.domain_id
    system.domain_name = "yourdomain.net"
    system.save!
    new_id = system.domain_id
    refute_equal orig_id, new_id
  end

  # Test non-default AR extenstion *_nam where method is :label for belongs_to :system_group
  test "should return system_group label using method #system_group_name" do
    system = systems(:one)
    system.update_attribute(:system_group, system_groups(:inherited))
    assert_equal "Parent/inherited", system.system_group_name
  end

  test "should update system_group_id by passing existing system_group label" do
    system = systems(:one)
    orig_id = system.system_group_id
    system.system_group_name = "Parent/inherited"
    system.save!
    new_id = system.system_group_id
    refute_equal orig_id, new_id
  end


end