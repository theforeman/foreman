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
    assert_equal "Common", tmplt.hostgroups.to_s
    assert_equal "production", tmplt.environments.to_s
  end

  def test_should_not_save_assoications_if_snippet
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

  # If the template is not a snippet is should require the specific declaration
  # of a type (gpxe, finish, etc.)
  def test_should_require_a_template_kind
    tmplt = ConfigTemplate.new
    tmplt.name = "Some finish script"
    tmplt.template = "echo $HOME"

    assert !tmplt.save
  end

end
