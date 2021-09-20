# frozen_string_literal: true

require 'test_helper'

module ForemanAnsible
  # Test for the structured facts importer - its code mostly lives in Foreman
  # core, so only details have to be tested here.
  class StructuredFactImporterTest < ActiveSupport::TestCase
    test 'if host is not in Foreman, use hostname provided by call' do
      fake_host = Host.new(:name => 'fake')
      importer = FactImporters::Structured.new(
        fake_host,
        nil,
        facts_json
      )
      assert_equal fake_host, importer.send(:host)
    end

    test 'if host is in Foreman, use hostname provided by Ansible' do
      ansible_fqdn_host = FactoryBot.build(:host)
      ansible_fqdn_host.name = facts_json[:ansible_facts][:ansible_fqdn]
      ansible_fqdn_host.save

      importer = FactImporters::Structured.new(
        Host.new(:name => 'fake'),
        nil,
        facts_json
      )

      assert_equal ansible_fqdn_host, importer.send(:host)
    end

    def facts_json
      HashWithIndifferentAccess.new(read_json_fixture('facts/ansible_facts.json'))
    end
  end
end
