require "test_helper"

class FactsParserTest < ActiveSupport::TestCase
  attr_reader :importer

  def setup
    @importer = Facts::Parser.new facts
    User.current = users :admin
  end

  test "should return list of interfaces" do
    assert importer.interfaces.present?
    assert_not_nil importer.primary_interface
    assert importer.interfaces.keys.include?(importer.primary_interface)
  end

  test "should return an os" do
    assert_kind_of Operatingsystem, importer.operatingsystem
  end

  test "should raise on an invalid os" do
    @importer = Facts::Parser.new({})
    assert_raise ::Foreman::Exception do
      importer.operatingsystem
    end
  end
  test "should return an env" do
    assert_kind_of Environment, importer.environment
  end

  test "should return an arch" do
    assert_kind_of Architecture, importer.architecture
  end

  test "should return a model" do
    assert_kind_of Model, importer.model
  end

  test "should return a domain" do
    assert_kind_of Domain, importer.domain
  end

  test "should make non-numeric os version strings into numeric" do
    @importer = Facts::Parser.new({'operatingsystem'=>'AnyOS','operatingsystemrelease'=>'1&2.3y4'})
    data = importer.operatingsystem
    assert_equal '12', data.major
    assert_equal '34', data.minor
  end

  test "should allow OS version minor component to be nil" do
    @importer = Facts::Parser.new({'operatingsystem'=>'AnyOS','operatingsystemrelease'=>'6'})
    data = importer.operatingsystem
    assert_equal "AnyOS 6", data.to_s
    assert_equal '6', data.major
    assert_empty data.minor
  end

  test "release_name should be nil when lsbdistcodename isn't set on Debian" do
    @importer = Facts::Parser.new(debian_facts.delete_if { |k,v| k == "lsbdistcodename" })
    assert_equal nil, @importer.operatingsystem.release_name
  end

  test "should set os.release_name to the lsbdistcodename fact on Debian" do
    @importer = Facts::Parser.new(debian_facts)
    assert_equal 'wheezy', @importer.operatingsystem.release_name
  end

  test "should not set os.release_name to the lsbdistcodename on non-Debian OS" do
    assert_not_equal 'Santiago', @importer.operatingsystem.release_name
  end

  test "should set description field from lsbdistdescription" do
    assert_equal "RHEL Server 6.2", @importer.operatingsystem.description
  end

  test "should not alter description field if already set" do
    # Need to instantiate @importer once with normal facts
    assert_present @importer.operatingsystem
    # Now re-import with a different description
    facts_with_desc = facts.merge({:lsbdistdescription => "A different string"})
    @importer = Facts::Parser.new facts_with_desc
    assert_equal "RHEL Server 6.2", @importer.operatingsystem.description
  end

  test "should set description correctly for SLES" do
    @importer = Facts::Parser.new(sles_facts)
    assert_equal 'SLES 11 SP3', @importer.operatingsystem.description
  end

  test "should not set description if lsbdistdescription is missing" do
    facts.delete('lsbdistdescription')
    @importer = Facts::Parser.new(facts)
    refute @importer.operatingsystem.description
  end

  test "should set os.major and minor for from AIX facts" do
    @importer = Facts::Parser.new(aix_facts)
    assert_equal 'AIX', @importer.operatingsystem.family
    assert_equal '6100', @importer.operatingsystem.major
    assert_equal '0604', @importer.operatingsystem.minor
  end

  private

  def facts
  #  return the equivalent of Facter.to_hash
    @json ||= JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.json")))['facts']
  end

  def debian_facts
    JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + '/facts_debian.json')))['facts']
  end

  def sles_facts
    JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + '/facts_sles.json')))['facts']
  end

  def aix_facts
    JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + '/facts_aix.json')))['facts']
  end
end
