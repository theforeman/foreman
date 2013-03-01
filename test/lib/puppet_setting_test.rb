require 'test_helper'
require 'puppet_setting'

class PuppetSettingTest < ActiveSupport::TestCase
  setup do
    SETTINGS.stubs(:[]).with(:puppetconfdir).returns('/test/etc/puppet')
    SETTINGS.stubs(:[]).with(:puppetvardir).returns('/test/var/puppet')
    SETTINGS.stubs(:[]).with(:puppetgem).returns(false)
  end

  test "should always have puppetconfdir available" do
    assert_not_nil SETTINGS[:puppetconfdir]
  end

  test "should always have puppetvardir available" do
    assert_not_nil SETTINGS[:puppetvardir]
  end

  test "should find puppetmasterd on Puppet 2.x" do
    Puppet::PUPPETVERSION.stubs(:to_i).returns(2.7)
    PuppetSetting.any_instance.expects(:which).with('puppetmasterd', kind_of(Array)).returns('/opt/puppet/bin/puppetmasterd')
    File.stubs(:exists?).with('/opt/puppet/bin/puppetmasterd').returns(true)
    FileTest.stubs(:file?).with('/test/etc/puppet').returns(false)

    pm = PuppetSetting.new.send(:puppetmaster)
    assert_equal "/opt/puppet/bin/puppetmasterd --confdir /test/etc/puppet", pm
  end

  test "should find 'puppet master' and use --vardir on Puppet 3.x" do
    Puppet::PUPPETVERSION.stubs(:to_i).returns(3.0)
    PuppetSetting.any_instance.expects(:which).with('puppet', kind_of(Array)).returns('/opt/puppet/bin/puppet')
    File.stubs(:exists?).with('/opt/puppet/bin/puppet').returns(true)
    FileTest.stubs(:file?).with('/test/etc/puppet').returns(false)

    pm = PuppetSetting.new.send(:puppetmaster)
    assert_equal "/opt/puppet/bin/puppet master --confdir /test/etc/puppet --vardir /test/var/puppet", pm
  end

  test "should use --config if puppetconfdir is a file" do
    Puppet::PUPPETVERSION.stubs(:to_i).returns(3.0)
    SETTINGS.stubs(:[]).with(:puppetconfdir).returns('/test/etc/puppet/puppet.conf')
    PuppetSetting.any_instance.expects(:which).with('puppet', kind_of(Array)).returns('/opt/puppet/bin/puppet')
    File.stubs(:exists?).with('/opt/puppet/bin/puppet').returns(true)
    FileTest.stubs(:file?).with('/test/etc/puppet/puppet.conf').returns(true)

    pm = PuppetSetting.new.send(:puppetmaster)
    assert_equal "/opt/puppet/bin/puppet master --config /test/etc/puppet/puppet.conf --vardir /test/var/puppet", pm
  end

  test "should throw error if puppet master binary not found" do
    Puppet::PUPPETVERSION.stubs(:to_i).returns(3.0)
    ps = PuppetSetting.new
    ps.expects(:which).with('puppet', kind_of(Array)).returns(false)
    File.stubs(:exists?).with('/opt/puppet/bin/puppet').returns(false)
    assert_raise(RuntimeError, /unable to find/) { ps.send(:puppetmaster) }
  end

  test "should not modify PATH when 'puppetgem' setting enabled" do
    Puppet::PUPPETVERSION.stubs(:to_i).returns(2.7)
    SETTINGS.stubs(:[]).with(:puppetgem).returns(true)
    PuppetSetting.any_instance.expects(:which).with('puppetmasterd', []).returns('/custom/bin/puppetmasterd')
    File.stubs(:exists?).with('/custom/bin/puppetmasterd').returns(true)

    pm = PuppetSetting.new.send(:puppetmaster)
    assert_equal "/custom/bin/puppetmasterd --confdir /test/etc/puppet", pm
  end

  test "should use puppetmasterd --configprint to look up setting" do
    ps = PuppetSetting.new
    ps.instance_variable_set(:@puppetmaster, '/foo')
    ps.expects('`').with('/foo --configprint foo 2>&1').returns('bar')
    $?.expects(:success?).returns(true)
    assert_equal 'bar', ps.get('foo')
  end

  test "should use puppetmasterd --configprint to look up multiple settings" do
    ps = PuppetSetting.new
    ps.instance_variable_set(:@puppetmaster, '/foo')
    ps.expects('`').with('/foo --configprint foo,bar_baz 2>&1').returns("bar_baz = foo\nfoo = bar\n")
    $?.expects(:success?).returns(true)
    assert_equal({ "foo" => "bar", "bar_baz" => "foo" },
    ps.get('foo', 'bar_baz'))
  end

  test "should report error from puppetmasterd --configprint" do
    ps = PuppetSetting.new
    ps.instance_variable_set(:@puppetmaster, '/foo')
    ps.expects('`').with('/foo --configprint foo 2>&1').returns('bar')
    $?.expects(:success?).returns(false)
    assert_raise(RuntimeError, /unable to get foo/) { ps.get('foo') }
  end
end
