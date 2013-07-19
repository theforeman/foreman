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
            klasses[klass.name][key.to_s] = value_of_key(key, values)
          end
        else
          klasses[klass.name] = nil
        end
      end
      klasses
    end

    protected
    def class_parameters
      @keys ||= LookupKey.includes(:environment_classes).parameters_for_class(puppetclass_ids, environment_id)
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

