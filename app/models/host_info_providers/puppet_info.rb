module HostInfoProviders
  class PuppetInfo < HostInfo::Provider
    def host_info
      # Static parameters
      param = puppet_static_info
      info_hash = {}
      info_hash['classes'] = classes_info_hash
      info_hash['parameters'] = param
      info_hash['environment'] = param["foreman_env"] if Setting["enc_environment"] && param["foreman_env"].present?

      info_hash
    end

    def puppetclass_parameters
      keys = PuppetclassLookupKey.includes(:environment_classes).parameters_for_class(host.puppetclass_ids, host.environment_id)
      key_hash = hashed_class_keys(keys)
      values = keys.values_hash(host)

      klasses = {}
      host.classes.each do |klass|
        klasses[klass.name] = smart_class_params_for(klass, key_hash, values)
      end
      klasses
    end

    def inherited_puppetclass_parameters
      keys = PuppetclassLookupKey.includes(:environment_classes).parameters_for_class(host.puppetclass_ids, host.environment_id)

      keys.inherited_values(host).raw
    end

    private

    def puppet_static_info
      params = {}
      # maybe these should be moved to the common parameters, leaving them in for now
      params["puppetmaster"] = host.puppetmaster
      params["puppet_ca"]    = host.puppet_ca_server if ca_defined?
      params["foreman_env"]  = host.environment.to_s if has_environment?

      params.merge! networking_params if Setting[:ignore_puppet_facts_for_provisioning]

      params
    end

    def ca_defined?
      SETTINGS[:unattended] && host.puppetca_exists?
    end

    def has_environment?
      host.environment&.name
    end

    def networking_params
      {
        "ip"  => host.ip,
        "ip6" => host.ip6,
        "mac" => host.mac,
      }
    end

    def classes_info_hash
      return [] if host.environment.nil?
      puppetclass_parameters
    end

    def smart_class_params_for(klass, key_hash, values)
      return nil unless key_hash[klass.id]

      class_values = {}
      key_hash[klass.id].each do |key|
        key_value = values[key]
        class_values[key.to_s] = key_value unless key_value.nil?
      end

      return nil if class_values == {}
      class_values
    end

    def hashed_class_keys(keys)
      h = {}
      keys.each do |key|
        klass_id = key.environment_classes.first.puppetclass_id
        h[klass_id] ||= []
        h[klass_id] << key
      end
      h
    end
  end
end
