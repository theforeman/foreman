module Classification
  class ClassParam < Base
    def enc
      key_hash = hashed_class_parameters
      values   = values_hash

      klasses = {}
      classes.each do |klass|
        klasses[klass.name] ||= {}
        if key_hash[klass.id]
          key_hash[klass.id].each do |key|
            key_value = value_of_key(key, values)
            klasses[klass.name][key.to_s] = key_value unless key_value.nil?
          end
          klasses[klass.name] = nil if klasses[klass.name] == {}
        else
          klasses[klass.name] = nil
        end
      end
      klasses
    end

    protected

    def class_parameters
      @keys ||= PuppetclassLookupKey.includes(:environment_classes).parameters_for_class(puppetclass_ids, environment_id)
    end

    private

    def hashed_class_parameters
      h = {}
      class_parameters.each do |key|
        klass_id = key.environment_classes.first.puppetclass_id
        h[klass_id] ||= []
        h[klass_id] << key
      end
      h
    end
  end
end
