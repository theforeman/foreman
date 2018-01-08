module Classification
  # Responsible for proper rendering of classification results.
  # Caches all neccessary objects for proper render.
  # Exposes [] index for rendering the actual result and #raw attribute
  # to access the raw LookupKey => LookupValue hash.
  class ClassificationResult
    attr_reader :raw

    def initialize(raw_hash, host)
      @host = host
      @raw = raw_hash
      @safe_render = ParameterSafeRender.new(host)
    end

    # Returns an object stored inside the LookupValue object, including running all
    # neccessary validations and rendering.
    # Inputs:
    # key: LookupKey to retreive
    def [](key)
      value = extract_value(key)

      return nil if value[:managed]
      needs_late_validation = value[:value].contains_erb?
      value = @safe_render.render(value[:value])
      value = type_cast(key, value)
      validate_lookup_value(key, value) if needs_late_validation
      value
    end

    private

    def extract_value(key)
      key_hash = key_hash(key)
      if key_hash
        {:value => key_hash[:value], :managed => key_hash[:managed] }
      else
        default_value_method = %w(yaml json).include?(key.key_type) ? :default_value_before_type_cast : :default_value
        {:value => key.send(default_value_method), :managed => key.omit}
      end
    end

    def key_hash(key)
      raw[key.id][key.to_s] if raw[key.id]
    end

    def validate_lookup_value(key, value)
      lookup_value = key.lookup_values.build(:value => value)
      return true if lookup_value.validate_value
      raise "Invalid value '#{value}' of parameter #{key.id} '#{key.key}'"
    end

    def type_cast(key, value)
      Foreman::Parameters::Caster.new(key, :attribute_name => :default_value, :to => key.key_type, :value => value).cast
    rescue TypeError
      Rails.logger.warn "Unable to type cast #{value} to #{key.key_type}"
    end
  end
end
