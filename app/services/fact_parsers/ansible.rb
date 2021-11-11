# frozen_string_literal: true

module FactParsers
  # Override methods from Foreman app/services/fact_parser so that facts
  # representing host properties are understood when they come from Ansible.
  class Ansible < AbstractFactParser
    include Utility::Ansible::OperatingSystemParser
    attr_reader :facts

    def initialize(facts)
      facts = facts[:ansible_facts] if facts[:ansible_facts]
      @facts = HashWithIndifferentAccess.new(facts)
    end

    # Don't do anything as there's no env in Ansible
    def environment
    end

    def architecture
      name = facts[:ansible_architecture] || facts[:facter_architecture]
      Architecture.where(:name => name).first_or_create if name.present?
    end

    def model
      name = detect_fact([:ansible_product_name, :facter_virtual,
                          :facter_productname, :facter_model, :model])
      Model.where(:name => name.strip).first_or_create if name.present?
    end

    def domain
      name = detect_fact([:ansible_domain, :facter_domain,
                          :ohai_domain, :domain])
      Domain.where(:name => name).first_or_create if name.present?
    end

    def support_interfaces_parsing?
      true
    end

    # Move ansible's default interface first in the list of interfaces since
    # Foreman picks the first one that is usable. If ansible has no
    # preference otherwise at least sort the list.
    #
    # This method overrides app/services/fact_parser.rb on Foreman and returns
    # an array of interface names, ['eth0', 'wlan1', etc...]
    def get_interfaces
      return [] if facts[:ansible_os_family] == 'Windows'
      pref = facts[:ansible_default_ipv4] &&
          facts[:ansible_default_ipv4]['interface']
      if pref.present?
        (facts[:ansible_interfaces] - [pref]).unshift(pref)
      else
        ansible_interfaces
      end
    end

    def get_facts_for_interface(iface_name)
      interface = iface_name.tr('-', '_') # virbr1-nic -> virbr1_nic
      interface_facts = facts[:"ansible_#{interface}"]
      ipaddress = ip_from_interface(interface)
      ipaddress6 = ipv6_from_interface(interface)
      macaddress = mac_from_interface(interface)
      iface_facts = HashWithIndifferentAccess[
          interface_facts.merge(:ipaddress => ipaddress,
                                :ipaddress6 => ipaddress6,
                                :macaddress => macaddress)
      ]
      logger.debug { "Ansible interface #{interface} facts: #{iface_facts.inspect}" }
      iface_facts
    end

    def ipmi_interface
    end

    def boot_timestamp
      Time.zone.now.to_i - facts['ansible_uptime_seconds'].to_i
    end

    def virtual
      facts['ansible_virtualization_role'] == 'guest'
    end

    def ram
      facts['ansible_memtotal_mb'].to_i
    end

    def sockets
      facts['ansible_processor_count'].to_i
    end

    def cores
      facts['ansible_processor_cores'].to_i
    end

    def fact_name_class
      ForemanAnsible::FactName
    end

    def self.smart_proxy_features
      'Ansible'
    end

    def host_from_facts
      Host.find_by(:name => facts[:ansible_fqdn] || facts[:fqdn])
    end

    def self.facts_key
      :ansible_facts
    end

    private

    def ansible_interfaces
      return [] if facts[:ansible_interfaces].blank?
      facts[:ansible_interfaces].sort
    end

    def mac_from_interface(interface)
      facts[:"ansible_#{interface}"]['perm_macaddress'].presence || facts[:"ansible_#{interface}"]['macaddress']
    end

    def ip_from_interface(interface)
      return if facts[:"ansible_#{interface}"]['ipv4'].blank?
      if facts[:"ansible_#{interface}"]['ipv4'].is_a?(Array)
        facts[:"ansible_#{interface}"]['ipv4'][0]['address']
      else
        facts[:"ansible_#{interface}"]['ipv4']['address']
      end
    end

    def ipv6_from_interface(interface)
      return if facts[:"ansible_#{interface}"]['ipv6'].blank?

      facts[:"ansible_#{interface}"]['ipv6'].first['address']
    end

    # Returns first non-empty fact. Needed to check for empty strings.
    def detect_fact(fact_names)
      facts[
          fact_names.detect do |fact_name|
            facts[fact_name].present?
          end
      ]
    end
  end
end
