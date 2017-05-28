module Classification
  class ClassParam < Base
    def enc
      key_hash = hashed_class_keys(keys)
      values = keys.values_hash(host)

      klasses = {}
      classes.each do |klass|
        klasses[klass.name] = smart_class_params_for(klass, key_hash, values)
      end
      klasses
    end

    protected

    def keys
      @keys ||= PuppetclassLookupKey.includes(:environment_classes).parameters_for_class(puppetclass_ids, environment_id)
    end

    private

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
