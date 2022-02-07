# frozen_string_literal: true

require 'test_helper'

module ForemanChef
  class FactParserTest < ActiveSupport::TestCase
    test 'should detect CentOS Stream' do
      parser = ForemanChef::FactParser.new(stream_facts)
      os = parser.operatingsystem

      assert os.present?
      assert_equal 'CentOS', os.name
      assert_equal '8', os.major
      assert_empty os.minor
    end

    test 'should detect CentOS 7' do
      parser = ForemanChef::FactParser.new(centos_7_facts)
      os = parser.operatingsystem

      assert os.present?
      assert_equal 'CentOS', os.name
      assert_equal '7', os.major
      assert_equal '7', os.minor
    end

    test 'should detect CentOS 8 non stream version' do
      parser = ForemanChef::FactParser.new(centos_8_facts)
      os = parser.operatingsystem

      assert os.present?
      assert_equal 'CentOS', os.name
      assert_equal '8', os.major
      assert_equal '4', os.minor
    end

    def stream_facts
      HashWithIndifferentAccess.new(read_json_fixture('facts/chef_centos_stream.json'))
    end

    def centos_8_facts
      HashWithIndifferentAccess.new(read_json_fixture('facts/chef_centos_8.json'))
    end

    def centos_7_facts
      HashWithIndifferentAccess.new(read_json_fixture('facts/chef_centos_7.json'))
    end
  end
end
