require 'test_helper'

class EnvironmentTest < ActiveSupport::TestCase
  test "should have name" do
    env = Environment.new
    assert !env.valid?
  end

  test "name should be unique" do
    env = Environment.create :name => "foo"
    env2 = Environment.new :name => env.name
    assert !env2.valid?
  end

  test "name should have no spaces" do
    env = Environment.new :name => "f o o"
    assert !env.valid?
  end

  test "name should be alphanumeric" do
    env = Environment.new :name => "test&fail"
    assert !env.valid?
  end

  test "to_label should print name" do
    env = Environment.new :name => "foo"
    assert env.to_label == env.name
  end

  test "to_s should print name" do
    env = Environment.new :name => "foo"
    assert env.to_s == env.name
  end

  test "with Puppet previous to 0.25, self.puppetEnvs should import environments" do
    Puppet.settings.instance_variable_get(:@values)[:main][:environments] = "test,development,production"
    Puppet.settings.instance_variable_get(:@values)[:test][:modulepath] = "/test/some/path"
    Puppet.settings.instance_variable_get(:@values)[:development][:modulepath] = "/development/some/path"
    Puppet.settings.instance_variable_get(:@values)[:production][:modulepath] = "/production/some/path"

    environments = Environment.puppetEnvs

    assert_not_nil environments[:test]
    assert environments[:test] == "/test/some/path"
    assert_not_nil environments[:development]
    assert environments[:development] == "/development/some/path"
    assert_not_nil environments[:production]
    assert environments[:production] == "/production/some/path"
  end

  test "with Puppet later to 0.25, self.puppetEnvs should import environments" do
    Puppet.settings.instance_variable_get(:@values)[:main] = {}
    Puppet.settings.instance_variable_get(:@values)[:puppetmasterd] = {}

    Puppet.settings.instance_variable_get(:@values)[:test] = {:modulepath => "/test/some/path"}
    Puppet.settings.instance_variable_get(:@values)[:development] = {:modulepath => "/development/some/path"}
    Puppet.settings.instance_variable_get(:@values)[:production] = {:modulepath => "/production/some/path"}

    environments = Environment.puppetEnvs

    assert_nil environments[:main]
    assert_nil environments[:puppetmasterd]
    assert_not_nil environments[:test]
    assert environments[:test] == "/test/some/path"
    assert_not_nil environments[:development]
    assert environments[:development] == "/development/some/path"
    assert_not_nil environments[:production]
    assert environments[:production] == "/production/some/path"
  end

  test "if no env is defined by Puppet, self.puppetEnvs should define production" do
    Puppet.settings.instance_variable_get(:@values).clear
    environments = Environment.puppetEnvs
    assert_not_nil environments[:production]
  end

  test "self.importClasses should respect relationship between environments and puppet class" do
    Puppet.settings.instance_variable_get(:@values)[:development] = {:modulepath => "/development/some/path"}

    puppet_classes = ["class development_puppet_class {"]
    mock(Dir).glob("/development/some/path/*/manifests/**/*.pp") { puppet_classes }
    mock(File).read(anything) { StringIO.new(puppet_classes.first) }

    Environment.importClasses

    puppet_class = Puppetclass.find_by_name("development_puppet_class")
    assert_not_nil puppet_class

    environment = Environment.find_by_name("development")
    assert_not_nil environment

    assert puppet_class.environments.include?(environment)
  end
end
