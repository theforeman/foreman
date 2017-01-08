module Classification
  class GlobalParam < Base
    def enc
      values = keys.values_hash(host)
      parameters = {}
      keys.each do |key|
        parameters[key.to_s] = values[key]
      end
      parameters
    end

    protected

    def keys
      @keys ||= VariableLookupKey.global_parameters_for_class(puppetclass_ids)
    end
  end
end
