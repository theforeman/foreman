require 'test_helper'

class ConfigTemplateTest < ActiveSupport::TestCase
  def test_should_be_valid_when_selecting_a_kind
    tmplt               = ConfigTemplate.new
    tmplt.name          = "Default Kickstart"
    tmplt.template      = "Some kickstart goes here"
    tmplt.template_kind = template_kinds(:ipxe)
    assert tmplt.valid?
  end

  def test_should_be_valid_as_a_snippet
    tmplt          = ConfigTemplate.new
    tmplt.name     = "Default Kickstart"
    tmplt.template = "Some kickstart goes here"
    tmplt.snippet  = true
    assert tmplt.valid?
  end

  def test_should_be_invalid
    assert !ConfigTemplate.new.valid?
  end

  def test_should_save_assoications_if_not_snippet
    tmplt = ConfigTemplate.new
    tmplt.name = "Some finish script"
    tmplt.template = "echo $HOME"
    tmplt.template_kind = template_kinds(:finish)
    tmplt.snippet = false # this is the default, but it helps show the case
    tmplt.hostgroups << hostgroups(:common)
    tmplt.environments << environments(:production)
    as_admin do
      assert tmplt.save
    end
    assert_equal template_kinds(:finish), tmplt.template_kind
    assert_equal [hostgroups(:common)], tmplt.hostgroups
    assert_equal [environments(:production)], tmplt.environments
  end

  def test_should_not_save_assoications_if_snippet
    tmplt          = ConfigTemplate.new
    tmplt.name     = "Default Kickstart"
    tmplt.template = "Some kickstart goes here"
    tmplt.snippet  = true
    tmplt.template_kind = template_kinds(:ipxe)
    tmplt.hostgroups << hostgroups(:common)
    tmplt.environments << environments(:production)
    as_admin do
      assert tmplt.save
    end
    assert_equal nil,tmplt.template_kind
    assert_equal [],tmplt.hostgroups
    assert_equal [],tmplt.environments
    assert_equal [],tmplt.template_combinations
  end

  # If the template is not a snippet is should require the specific declaration
  # of a type (ipxe, finish, etc.)
  def test_should_require_a_template_kind
    tmplt = ConfigTemplate.new
    tmplt.name = "Some finish script"
    tmplt.template = "echo $HOME"

    assert !tmplt.save
  end

  describe "Association cascading" do
    setup do
      @os1 = FactoryGirl.create(:operatingsystem)
      @hg1 = FactoryGirl.create(:hostgroup)
      @hg2 = FactoryGirl.create(:hostgroup)
      @hg3 = FactoryGirl.create(:hostgroup)
      @ev1 = FactoryGirl.create(:environment)
      @ev2 = FactoryGirl.create(:environment)
      @ev3 = FactoryGirl.create(:environment)

      @tk = FactoryGirl.create(:template_kind)

      # Most specific template association
      @ct1 = FactoryGirl.create(:config_template, :template_kind => @tk, :operatingsystems => [@os1])
      @ct1.template_combinations.create(:hostgroup => @hg1, :environment => @ev1)

      # HG only
      # We add an association on HG2/EV2 to ensure that we're not just blindly
      # selecting all template_combinations where environment_id => nil
      @ct2 = FactoryGirl.create(:config_template, :template_kind => @tk, :operatingsystems => [@os1])
      @ct2.template_combinations.create(:hostgroup => @hg1, :environment => nil)
      @ct2.template_combinations.create(:hostgroup => @hg2, :environment => @ev2)

      # Env only
      # We add an association on HG2/EV2 to ensure that we're not just blindly
      # selecting all template_combinations where hostgroup_id => nil
      @ct3 = FactoryGirl.create(:config_template, :template_kind => @tk, :operatingsystems => [@os1])
      @ct3.template_combinations.create(:hostgroup => nil, :environment => @ev1)
      @ct3.template_combinations.create(:hostgroup => @hg2, :environment => @ev2)

      # Default template for the OS
      @ctd = FactoryGirl.create(:config_template, :template_kind => @tk, :operatingsystems => [@os1])
      @ctd.os_default_templates.create(:operatingsystem => @os1,
                                      :template_kind_id => @ctd.template_kind_id)
    end

    test "find_template finds a matching template with hg and env" do
      assert_equal @ct1.name,
        ConfigTemplate.find_template({:kind => @tk.name,
                                      :operatingsystem_id => @os1.id,
                                      :hostgroup_id => @hg1.id,
                                      :environment_id => @ev1.id}).name
    end
    test "find_template finds a matching template with hg only" do
      assert_equal @ct2.name,
        ConfigTemplate.find_template({:kind => @tk.name,
                                      :operatingsystem_id => @os1.id,
                                      :hostgroup_id => @hg1.id}).name
    end
    test "find_template finds a matching template with hg and mismatched env" do
      assert_equal @ct2.name,
        ConfigTemplate.find_template({:kind => @tk.name,
                                      :operatingsystem_id => @os1.id,
                                      :hostgroup_id => @hg1.id,
                                      :environment_id => @ev3.id}).name
    end
    test "find_template finds a matching template with env only" do
      assert_equal @ct3.name,
        ConfigTemplate.find_template({:kind => @tk.name,
                                      :operatingsystem_id => @os1.id,
                                      :environment_id => @ev1.id}).name
    end
    test "find_template finds a matching template with env and mismatched hg" do
      assert_equal @ct3.name,
        ConfigTemplate.find_template({:kind => @tk.name,
                                      :operatingsystem_id => @os1.id,
                                      :hostgroup_id => @hg3.id,
                                      :environment_id => @ev1.id}).name
    end
    test "find_template finds the default template when hg and env do not match" do
      assert_equal @ctd.name,
        ConfigTemplate.find_template({:kind => @tk.name,
                                      :operatingsystem_id => @os1.id,
                                      :hostgroup_id => @hg3.id,
                                      :environment_id => @ev3.id}).name
    end
  end

end
