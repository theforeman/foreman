require 'test_helper'

class ConfigTemplateTest < ActiveSupport::TestCase
  def test_should_be_valid_when_selecting_a_kind
    tmplt               = ConfigTemplate.new
    tmplt.name          = "Default Kickstart"
    tmplt.template      = "Some kickstart goes here"
    tmplt.template_kind = template_kinds(:gpxe)
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

  def test_should_not_save_associations_if_snippet
    tmplt          = ConfigTemplate.new
    tmplt.name     = "Default Kickstart"
    tmplt.template = "Some kickstart goes here"
    tmplt.snippet  = true
    tmplt.template_kind = template_kinds(:gpxe)
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
#TODO Add many more tests here

end
