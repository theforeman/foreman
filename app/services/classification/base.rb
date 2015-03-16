module Classification
  class Base

    delegate :hostgroup, :environment_id, :puppetclass_ids, :classes,
             :to => :host

    def initialize(args = {})
      @host = args[:host]
      @safe_render = SafeRender.new(:variables => {:host => host})
    end

    #override to return the relevant enc data and format
    def enc
      raise NotImplementedError
    end

    def inherited_values
      values_hash :skip_fqdn => true
    end

    protected

    attr_reader :host

    #override this method to return the relevant parameters for a given set of classes
    def class_parameters
      raise NotImplementedError
    end

    def possible_value_orders
      class_parameters.select do |key|
        # take only keys with actual values
        key.lookup_values_count > 0 # we use counter cache, so its safe to make that query
      end.map(&:path_elements).flatten(1).uniq
    end

    def values_hash(options = {})
      values = Hash.new { |h,k| h[k] = {} }
      all_lookup_values = LookupValue.where(:match => path2matches).where(:lookup_key_id => class_parameters)
      class_parameters.each do |key|
        lookup_values_for_key = all_lookup_values.where(:lookup_key_id => key.id, :use_puppet_default => false).includes(:lookup_key)
        sorted_lookup_values = lookup_values_for_key.sort_by do |lv|
          # splitting the matcher hostgroup=example to 'hostgroup' and 'example'
          matcher_element, matcher_value = lv.match.split(LookupKey::EQ_DELM)
          # prefer matchers in order of the path, then more specific matches (i.e. hostgroup children)
          [key.path.index(matcher_element), -1 * matcher_value.length]
        end
        value = nil
        if key.merge_overrides
          case key.key_type
            when "array"
              value = update_array_matcher(key.avoid_duplicates, sorted_lookup_values, options)
            when "hash"
              value = update_hash_matcher(sorted_lookup_values, options)
            else
              raise "merging enabled for non mergeable key #{key.key}"
          end
        else
          value = update_generic_matcher(sorted_lookup_values, options)
        end

        if value.present?
          values[key.id][key.key] = value
        end
      end
      values
    end

    def value_of_key(key, values)
      value = if values[key.id] and values[key.id][key.to_s]
                {:value => values[key.id][key.to_s][:value]}
              else
                default_value_method = %w(yaml json).include?(key.key_type) ? :default_value_before_type_cast : :default_value
                {:value => key.send(default_value_method), :managed => key.use_puppet_default}
              end

      return nil if value[:managed]
      needs_late_validation = key.contains_erb?(value[:value])
      value = @safe_render.parse(value[:value])
      value = type_cast(key, value)
      validate_lookup_value(key, value) if needs_late_validation
      value
    end

    def hostgroup_matches
      @hostgroup_matches ||= matches_for_hostgroup
    end

    def matches_for_hostgroup
      matches = []
      if hostgroup
        path = hostgroup.to_label
        while path.include?("/")
          path = path[0..path.rindex("/")-1]
          matches << "hostgroup#{LookupKey::EQ_DELM}#{path}"
        end
      end
      matches
    end

    # Generate possible lookup values type matches to a given host
    def path2matches
      matches = []
      possible_value_orders.each do |rule|
        match = Array.wrap(rule).map do |element|
          "#{element}#{LookupKey::EQ_DELM}#{attr_to_value(element)}"
        end
        matches << match.join(LookupKey::KEY_DELM)

        hostgroup_matches.each do |hostgroup_match|
          match[match.index { |m| m =~ /hostgroup\s*=/ }]=hostgroup_match
          matches << match.join(LookupKey::KEY_DELM)
        end if Array.wrap(rule).include?("hostgroup") && Setting["host_group_matchers_inheritance"]
      end
      matches
    end

    # translates an element such as domain to its real value per host
    # tries to find the host attribute first, parameters and then fallback to a puppet fact.
    def attr_to_value(element)
      # direct host attribute
      return host.send(element) if host.respond_to?(element)
      # host parameter
      return host.host_params[element] if host.host_params.include?(element)
      # fact attribute
      if (fn = host.fact_names.first(:conditions => {:name => element}))
        return FactValue.where(:host_id => host.id, :fact_name_id => fn.id).first.value
      end
    end

    def path_elements(path = nil)
      path.split.map do |paths|
        paths.split(LookupKey::KEY_DELM).map do |element|
          element
        end
      end
    end

    private

    def validate_lookup_value(key, value)
      lookup_value = key.lookup_values.build(:value => value)
      return true if lookup_value.send(:validate_list) && lookup_value.send(:validate_regexp)
      raise "Invalid value '#{value}' of parameter #{key.id} '#{key.key}'"
    end

    def type_cast(key, value)
      key.cast_validate_value(value)
    rescue TypeError
      Rails.logger.warn "Unable to type cast #{value} to #{key.key_type}"
    end

    def update_generic_matcher(lookup_values, options)
      computed_lookup_value = nil
      lookup_values.each do |lookup_value|
        element, element_name = lookup_value.match.split(LookupKey::EQ_DELM)
        next if (options[:skip_fqdn] && element=="fqdn")
        value_method = %w(yaml json).include?(lookup_value.lookup_key.key_type) ? :value_before_type_cast : :value
        computed_lookup_value = {:value => lookup_value.send(value_method), :element => element,
                                 :element_name => element_name}
        break
      end
      computed_lookup_value
    end

    def update_array_matcher(should_avoid_duplicates, lookup_values, options)
      elements = []
      values = []
      element_names = []

      lookup_values.each do |lookup_value|
        element, element_name = lookup_value.match.split(LookupKey::EQ_DELM)
        next if (options[:skip_fqdn] && element=="fqdn")
        elements << element
        element_names << element_name
        if should_avoid_duplicates
          values |= lookup_value.value
        else
          values += lookup_value.value
        end
      end

      return nil unless values.present?
      {:value => values, :element => elements, :element_name => element_names}
    end

    def update_hash_matcher(lookup_values, options)
      elements = []
      values = {}
      element_names = []

      # to make sure seep merge overrides by priority, putting in the values with the lower priority first
      # and then merging with higher priority
      lookup_values.reverse.each do |lookup_value|
        element, element_name = lookup_value.match.split(LookupKey::EQ_DELM)
        next if (options[:skip_fqdn] && element=="fqdn")
        elements << element
        element_names << element_name
        values.deep_merge!(lookup_value.value)
      end

      return nil unless values.present?
      {:value => values, :element => elements, :element_name => element_names}
    end
  end
end
