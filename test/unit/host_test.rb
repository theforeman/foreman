require 'test_helper'

class HostTest < ActiveSupport::TestCase
  test "should not save without a hostname" do
    host = Host.new
    assert !host.save
  end

  test "should fix mac address" do
    host = Host.create :name => "myhost", :mac => "aabbccddeeff"
    assert_equal "aa:bb:cc:dd:ee:ff", host.mac
  end

  test "should fix ip address if a leading zero is used" do
    host = Host.create :name => "myhost", :mac => "aabbccddeeff", :ip => "123.01.02.03"
    assert_equal "123.1.2.3", host.ip
  end

  test "should add domain name to hostname" do
    host = Host.create :name => "myhost", :mac => "aabbccddeeff", :ip => "123.01.02.03",
      :domain => Domain.find_or_create_by_name("company.com")
    assert_equal "myhost.company.com", host.name
  end

  test "should be able to save host" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"
    puts host.errors.full_messages
    assert host.valid?
  end

  test "should import facts from yaml stream" do
    h=Host.new(:name => "sinn1636.lan")
    h.disk = "!" # workaround for now
    h.importFacts YAML::load(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.yml")))
    assert h.valid?
  end

  test "should import facts from yaml of a new host" do
    assert Host.importHostAndFacts File.read(File.expand_path(File.dirname(__FILE__) + "/facts.yml"))
  end


  test "should not save if both ptable and disk are not defined" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first
    assert !host.valid?
  end

  test "should save if ptable is defined" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :ptable => Ptable.first
    assert host.valid?
  end

  test "should save if disk is defined" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "aaa"
    assert host.valid?
  end

end
