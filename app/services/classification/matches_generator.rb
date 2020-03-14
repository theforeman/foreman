module Classification
  # Responsible for generation of matcher strings for a given host and set of keys
  class MatchesGenerator
    def self.matches(host, keys)
      new(host, keys).matches
    end

    attr_reader :host, :keys
    def initialize(host, keys)
      @host = host
      @keys = keys
    end

    def matches
      matches = []
      possible_value_orders.each do |rule|
        match = generate_match(rule)
        matches << match.join(LookupKey::KEY_DELM)
        LookupKey::MATCHERS_INHERITANCE.each do |element|
          if add_inherited_matches?(element, rule)
            inherited_matches(element).each do |inherited_match|
              match[match.index { |m| m =~ /#{element}\s*=/ }] = inherited_match
              matches << match.join(LookupKey::KEY_DELM)
            end
          end
        end
      end
      matches
    end

    private

    def possible_value_orders
      # the inner join makes sure we take only keys with actual values
      keys.joins(:lookup_values).flat_map(&:path_elements).uniq
    end

    def generate_match(rule)
      Array.wrap(rule).map do |element|
        "#{element}#{LookupKey::EQ_DELM}#{attr_to_value(element)}"
      end
    end

    def add_inherited_matches?(element, rule)
      Array.wrap(rule).include?(element) && Setting['matchers_inheritance']
    end

    # translates an element such as domain to its real value per host
    # tries to find the host attribute first, parameters and then fallback to a puppet fact.
    def attr_to_value(element)
      # direct host attribute
      return host.send(element) if is_method?(element)
      # host parameter
      return host.host_params[element] if is_parameter?(element)
      # fact attribute
      if (fn = fact_name(element))
        fact_value(fn)
      end
    end

    def is_method?(element)
      host.respond_to?(element)
    end

    def is_parameter?(element)
      host.host_params.include?(element)
    end

    def inherited_matches(element)
      matches = []
      if host.send(element)
        path = host.send(element).to_label
        while path.include?("/")
          path = path[0..path.rindex("/") - 1]
          matches << "#{element}#{LookupKey::EQ_DELM}#{path}"
        end
      end
      matches
    end

    def fact_name(element)
      host.fact_names.where(:name => element).first
    end

    def fact_value(fact_name)
      FactValue.where(:host_id => host.id, :fact_name_id => fact_name.id).first.value
    end

    def path_elements(path = nil)
      path.split.map do |paths|
        paths.split(LookupKey::KEY_DELM).map do |element|
          element
        end
      end
    end
  end
end
