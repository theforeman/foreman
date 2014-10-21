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
        lookup_values_for_key = all_lookup_values.where(:lookup_key_id => key.id)
        sorted_lookup_values = lookup_values_for_key.sort_by { |lv| key.path.index(lv.match.split(LookupKey::EQ_DELM).first) }
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
                values[key.id][key.to_s][:value]
              else
                key.default_value
              end
      @safe_render.parse(value)
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

    def update_generic_matcher(lookup_values, options)
      if options[:skip_fqdn]
        while lookup_values.present? && lookup_values.first.match.split(LookupKey::EQ_DELM).first == "fqdn"
          lookup_values.delete_at(0)
        end
      end

      if lookup_values.present?
        lv = lookup_values.first
        element, element_name = lv.match.split(LookupKey::EQ_DELM)
        {:value => lv.value, :element => element,
         :element_name => element_name}
      end
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

      {:value => values, :element => elements,
       :element_name => element_names}
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

      {:value => values, :element => elements,
       :element_name => element_names}
    end
  end
end