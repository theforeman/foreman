module Classification
  module ValuesHashQuery
    class << self
      # Calculates values for a given set of keys and host, but returns only values that were not set
      # on the host itself (inherited from different properties like hostgroup, interface e.t.c.).
      # See values_hash for more info.
      def inherited_values(host, keys)
        values_hash host, keys, :skip_fqdn => true
      end

      # Calculates values for a given set of keys and a host supplied in the constructor.
      # Inputs:
      # keys: an ActiveRecord::Scope with a set of LookupKey instances
      # options:
      #   :skip_fqdn => true, if there is no need to calculate values specified directly for the host.
      # returns: ClassificationResult instance.
      def values_hash(host, keys, options = {})
        lookup_values_cache = lookup_values(host, keys)
        values = Hash.new { |h, k| h[k] = {} }
        keys.each do |key|
          value = calculate_value(key, lookup_values_cache, options)
          values[key.id][key.key] = value if value.present?
        end
        Classification::ClassificationResult.new(values, host)
      end

      private

      def lookup_values(host, keys)
        LookupValue.where(:match => Classification::MatchesGenerator.matches(host, keys)).where(:lookup_key_id => keys).includes(:lookup_key).to_a
      end

      def calculate_value(key, lookup_values_cache, options)
        lookup_values_for_key = lookup_values_cache.select { |i| i.lookup_key_id == key.id }
        sorted_lookup_values = sort_lookup_values(key, lookup_values_for_key)
        value = nil
        if key.merge_overrides
          value = merged_value(key, sorted_lookup_values, options)
        else
          value = update_generic_matcher(sorted_lookup_values, options)
        end

        value
      end

      def merged_value(key, sorted_lookup_values, options)
        default = key.merge_default ? key.default_value : nil
        case key.key_type
          when "array"
            value = update_array_matcher(default, key.avoid_duplicates, sorted_lookup_values, options)
          when "hash"
            value = update_hash_matcher(default, sorted_lookup_values, options)
          else
            raise "merging enabled for non mergeable key #{key.key}"
        end

        value
      end

      def sort_lookup_values(key, lookup_values)
        lookup_values.sort_by do |lv|
          matcher_key, matcher_value = split_matcher(lv)
          # prefer matchers in order of the path, then more specific matches (i.e. hostgroup children)
          [key.path.split.index(matcher_key.chomp(',')), -1 * matcher_value.length]
        end
      end

      def split_matcher(lookup_value)
        matcher_key = ''
        matcher_value = ''

        lookup_value.match.split(LookupKey::KEY_DELM).each do |match_keyval|
          key, value = match_keyval.split(LookupKey::EQ_DELM)
          matcher_key += key + ','
          if LookupKey::MATCHERS_INHERITANCE.include?(key)
            matcher_value += value + ','
          end
        end

        [matcher_key, matcher_value]
      end

      def get_element_and_element_name(lookup_value)
        element = ''
        element_name = ''
        lookup_value.match.split(LookupKey::KEY_DELM).each do |match_key|
          lv_element, lv_element_name = match_key.split(LookupKey::EQ_DELM)
          element += lv_element + ','
          element_name += lv_element_name + ','
        end
        [element.chomp(','), element_name.chomp(',')]
      end

      def update_generic_matcher(lookup_values, options)
        computed_lookup_value = nil
        lookup_values.each do |lookup_value|
          element, element_name = get_element_and_element_name(lookup_value)
          next if (options[:skip_fqdn] && element == "fqdn")
          computed_lookup_value = compute_lookup_value(lookup_value, element, element_name)
          computed_lookup_value[:managed] = lookup_value.omit if lookup_value.lookup_key.puppet?
          break
        end
        computed_lookup_value
      end

      def compute_lookup_value(lookup_value, element, element_name)
        value_method = %w(yaml json).include?(lookup_value.lookup_key.key_type) ? :value_before_type_cast : :value
        {
          :value => lookup_value.send(value_method),
          :element => element,
          :element_name => element_name,
        }
      end

      def update_array_matcher(default, should_avoid_duplicates, lookup_values, options)
        values, elements, element_names = set_defaults(default, [])

        lookup_values.each do |lookup_value|
          element, element_name = get_element_and_element_name(lookup_value)
          next if skip_value?(element, lookup_value, options)
          elements << element
          element_names << element_name

          values = accumulate_value(values, lookup_value, should_avoid_duplicates)
        end

        return nil unless values.present?
        {:value => values, :element => elements, :element_name => element_names}
      end

      def skip_value?(element, lookup_value, options)
        ((options[:skip_fqdn] && element == "fqdn") || lookup_value.omit)
      end

      def accumulate_value(values, lookup_value, should_avoid_duplicates)
        if should_avoid_duplicates
          values |= lookup_value.value
        else
          values += lookup_value.value
        end
        values
      end

      def set_defaults(default, empty_value)
        return [empty_value, [], []] if default.nil?

        [default, [s_("LookupKey|Default value")], [s_("LookupKey|Default value")]]
      end

      def update_hash_matcher(default, lookup_values, options)
        values, elements, element_names = set_defaults(default, {})

        # to make sure seep merge overrides by priority, putting in the values with the lower priority first
        # and then merging with higher priority
        lookup_values.reverse_each do |lookup_value|
          element, element_name = get_element_and_element_name(lookup_value)
          next if skip_value?(element, lookup_value, options)
          elements << element
          element_names << element_name
          values.deep_merge!(lookup_value.value)
        end

        return nil unless values.present?
        {:value => values, :element => elements, :element_name => element_names}
      end
    end
  end
end
