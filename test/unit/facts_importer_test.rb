require "test_helper"

class FactsImporterTest < ActiveSupport::TestCase
  attr_reader :importer

  def setup
    @importer = Facts::Importer.new facts
    User.current = User.admin
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
    @importer = Facts::Importer.new({})
    assert_raise RuntimeError do
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

  private

  def facts
  #  return Facter.to_hash
    @yaml ||= YAML::load(File.read(File.expand_path(File.dirname(__FILE__) + "/facts.yml"))).values
  end

end