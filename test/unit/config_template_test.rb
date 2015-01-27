require 'test_helper'

class ConfigTemplateTest < ActiveSupport::TestCase
  test "should be valid when selecting a kind" do
    tmplt               = ConfigTemplate.new
    tmplt.name          = "Default Kickstart"
    tmplt.template      = "Some kickstart goes here"
    tmplt.template_kind = template_kinds(:ipxe)
    assert tmplt.valid?
  end

  test "should be valid as a snippet" do
    tmplt          = ConfigTemplate.new
    tmplt.name     = "Default Kickstart"
    tmplt.template = "Some kickstart goes here"
    tmplt.snippet  = true
    assert tmplt.valid?
  end

  test "should be invalid" do
    assert !ConfigTemplate.new.valid?
  end

  test "should save assoications if not snippet" do
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

  test "should not save assoications if snippet" do
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
  test "should require a template kind" do
    tmplt = ConfigTemplate.new
    tmplt.name = "Some finish script"
    tmplt.template = "echo $HOME"

    assert !tmplt.save
  end

  test "should be able to clone" do
    tmplt          = ConfigTemplate.new
    tmplt.name     = "Finish It"
    tmplt.template = "some content"
    tmplt.snippet  = false
    tmplt.template_kind = template_kinds(:finish)
    as_admin do
      assert tmplt.save
    end
    clone = tmplt.clone

    assert_equal clone.name, nil
    assert_equal clone.operatingsystems, tmplt.operatingsystems
    assert_equal clone.template_kind_id, tmplt.template_kind_id
    assert_equal clone.template, tmplt.template
  end

  test "should not edit a locked template" do
    tmplt = config_templates(:locked)
    tmplt.name = "something else"
    refute_valid tmplt, :base, /is locked/
  end

  test "should clone a locked template as unlocked" do
    tmplt = config_templates(:locked)
    clone = tmplt.clone
    assert_equal clone.name, nil
    assert_equal clone.operatingsystems, tmplt.operatingsystems
    assert_equal clone.template_kind_id, tmplt.template_kind_id
    assert_equal clone.template, tmplt.template
    assert tmplt.locked
    refute clone.locked
  end

  test "should not remove a locked template" do
    tmplt = config_templates(:locked)
    refute_with_errors tmplt.destroy, tmplt, :base, /locked/
  end

  test "should not unlock a template if not allowed" do
    tmplt = ConfigTemplate.create :name => "Vendor Template", :template => "provision test",
                                  :template_kind => template_kinds(:provision), :default => true,
                                  :vendor => "Katello"
    tmplt.update_attribute(:locked, true)
    User.current = FactoryGirl.create(:user)
    tmplt.locked = false
    refute_valid tmplt, :base, /not authorized/
  end

  test "should change a locked template while in rake" do
    Foreman.stubs(:in_rake?).returns(true)
    tmplt = config_templates(:locked)
    tmplt.template = "changing the template content"
    tmplt.name = "giving it a new name too"
    assert tmplt.locked
    assert_valid tmplt
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
