require 'test_helper'

module ForemanSalt
  class SaltFactsParserTest < ActiveSupport::TestCase
    def setup
      grains = JSON.parse(File.read(File.join(Rails.root, 'test', 'static_fixtures', 'facts', 'grains_centos.json')))
      @facts_parser = ForemanSalt::FactParser.new grains["facts"]
      User.current = users :admin
    end

    test "should return list of interfaces" do
      assert @facts_parser.interfaces.present?
      assert_not_nil @facts_parser.suggested_primary_interface(FactoryBot.build(:host))
      assert @facts_parser.interfaces.key?(@facts_parser.suggested_primary_interface(FactoryBot.build(:host)).first)
    end

    test "should set operatingsystem correctly" do
      os = @facts_parser.operatingsystem
      assert os.present?
      assert_equal 'CentOS', os.name
      assert_equal '6', os.major
      assert_equal '5', os.minor
      assert_equal 'CentOS 6.5', os.title
    end

    test "should identify CentOS Stream correctly" do
      facts = HashWithIndifferentAccess.new(read_json_fixture("facts/salt_centos_stream.json"))
      parser = ForemanSalt::FactParser.new(facts)
      os = parser.operatingsystem

      assert os.present?
      assert_equal 'CentOS', os.name
      assert_equal '8', os.major
      assert_empty os.minor
    end

    test "should identify CentOS 8 correctly" do
      facts = HashWithIndifferentAccess.new(read_json_fixture("facts/salt_centos_8.json"))
      parser = ForemanSalt::FactParser.new(facts)
      os = parser.operatingsystem

      assert os.present?
      assert_equal 'CentOS', os.name
      assert_equal '8', os.major
      assert_equal '4.2105', os.minor
    end

    test "should set domain correctly" do
      domain = @facts_parser.domain
      assert domain.present?
      assert_equal 'example.com', domain.name
    end

    test "should set ip correctly" do
      assert_equal '10.7.13.141', @facts_parser.ip
    end

    test "should set primary_interface correctly" do
      assert_equal 'eth0', @facts_parser.primary_interface
    end

    test "should set mac correctly" do
      assert_equal '52:54:00:35:30:2a', @facts_parser.mac
    end
  end
end
