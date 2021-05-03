# frozen_string_literal: true

module ForemanAnsible
  # On 1.13+ , use the parser for structured facts (like Facter 2) that comes
  # from core
  class StructuredFactImporter < ::StructuredFactImporter
    def fact_name_class
      ForemanAnsible::FactName
    end

    def self.authorized_smart_proxy_features
      'Ansible'
    end

    def initialize(host, facts = {})
      # Try to assign these facts to the correct host as per the facts say
      # If that host isn't created yet, the host parameter will contain it
      @host = Host.find_by(:name => facts[:ansible_facts][:ansible_fqdn] ||
                                    facts[:ansible_facts][:fqdn]) ||
              host
      @facts = normalize(facts[:ansible_facts])
      @counters = {}
    end
  end
end
