module Classification
  class Base
    delegate :system_group, :environment_id,
             :to => :system

    def initialize args = { }
      @system = args[:system]
      @safe_render = SafeRender.new(:variables => { :system => system } )
    end

    #override to return the relevant enc data and format
    def enc
      raise NotImplementedError
    end

    def inherited_values
      values_hash :skip_fqdn => true
    end

    protected

    attr_reader :system

    #override this method to return the relevant parameters for a given set of classes
    def class_parameters
      raise NotImplementedError
    end

    def puppetclass_ids
      return @puppetclass_ids if @puppetclass_ids
      ids = system.system_classes.pluck(:puppetclass_id)
      ids += SystemGroupClass.where(:system_group_id => system_group.path_ids).pluck(:puppetclass_id) if system_group
      @puppetclass_ids = if Setting['remove_classes_not_in_environment']
                           EnvironmentClass.where(:environment_id => system.environment_id, :puppetclass_id => ids).
                               pluck('DISTINCT puppetclass_id')
                         else
                           ids
                         end
    end

    def classes
      Puppetclass.where(:id => puppetclass_ids)
    end

    def possible_value_orders
      class_parameters.select do |key|
        # take only keys with actual values
        key.lookup_values_count > 0 # we use counter cache, so its safe to make that query
      end.map(&:path_elements).flatten(1).uniq
    end

    def values_hash options={}
      values = {}
      path2matches.each do |match|
        LookupValue.where(:match => match).where(:lookup_key_id => class_parameters.map(&:id)).each do |value|
          key_id = value.lookup_key_id
          values[key_id] ||= {}
          key = class_parameters.detect{|k| k.id == value.lookup_key_id }
          name = key.to_s
          element = match.split(LookupKey::EQ_DELM).first
          next if options[:skip_fqdn] && element=="fqdn"
          if values[key_id][name].nil?
            values[key_id][name] = {:value => value.value, :element => element}
          else
            if key.path.index(element) < key.path.index(values[key_id][name][:element])
              values[key_id][name] = {:value => value.value, :element => element}
            end
          end
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

    def system_group_matches
      @system_group_matches ||= matches_for_system_group
    end

    def matches_for_system_group
      matches = []
      if system_group
        path = system_group.to_label
        while path.include?("/")
          path = path[0..path.rindex("/")-1]
          matches << "system_group#{LookupKey::EQ_DELM}#{path}"
        end
      end
      matches
    end

    # Generate possible lookup values type matches to a given system
    def path2matches
      matches = []
      possible_value_orders.each do |rule|
        match = Array.wrap(rule).map do |element|
          "#{element}#{LookupKey::EQ_DELM}#{attr_to_value(element)}"
        end
        matches << match.join(LookupKey::KEY_DELM)

        system_group_matches.each do |system_group_match|
          match[match.index{|m|m =~ /system_group\s*=/}]=system_group_match
          matches << match.join(LookupKey::KEY_DELM)
        end if Array.wrap(rule).include?("system_group") && Setting["system_group_matchers_inheritance"]
      end
      matches
    end

    # translates an element such as domain to its real value per system
    # tries to find the system attribute first, parameters and then fallback to a puppet fact.
    def attr_to_value element
      # direct system attribute
      return system.send(element) if system.respond_to?(element)
      # system parameter
      return system.system_params[element] if system.system_params.include?(element)
      # fact attribute
      if (fn = system.fact_names.first(:conditions => { :name => element }))
        return FactValue.where(:system_id => system.id, :fact_name_id => fn.id).first.value
      end
    end

    def path_elements path = nil
      path.split.map do |paths|
        paths.split(LookupKey::KEY_DELM).map do |element|
          element
        end
      end
    end
  end
end

