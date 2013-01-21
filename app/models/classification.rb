class Classification
  delegate :hostgroup, :environment_id,
           :to => :host

  def initialize args = { }
    @host = args[:host]
  end

  def enc
    klasses  = { }
    key_hash = hashed_class_parameters
    values   = values_hash
    classes.each do |klass|
      klasses[klass.name] ||= { }
      if key_hash[klass.id]
        key_hash[klass.id].each do |param|
          klasses[klass.name][param.to_s] = if values[param.id] and values[param.id][param.to_s]
                                              values[param.id][param.to_s][:value]
                                            else
                                              param.default_value
                                            end
        end
      else
        klasses[klass.name] = nil
      end
    end
    klasses
  end

  private

  attr_reader :host

  def puppetclass_ids
    return @puppetclass_ids if @puppetclass_ids
    @puppetclass_ids = host.host_classes.pluck(:puppetclass_id)
    @puppetclass_ids +=  HostgroupClass.where(:hostgroup_id => hostgroup.path_ids).pluck(:puppetclass_id) if hostgroup

    @puppetclass_ids
  end

  def classes
    Puppetclass.where(:id => puppetclass_ids)
  end

  def class_parameters
    @keys ||= LookupKey.includes(:environment_classes).parameters_for_class(puppetclass_ids, environment_id)
  end

  def possible_value_orders
    class_parameters.select do |key|
      # take only keys with actual values
      key.lookup_values_count > 0 # we use counter cache, so its safe to make that query
    end.map(&:path_elements).flatten(1).uniq
  end

  def values_hash
    values = {}
    path2matches.each do |match|
      LookupValue.where(:match => match).where(:lookup_key_id => class_parameters.map(&:id)).each do |value|
        key_id = value.lookup_key_id
        values[key_id] ||= {}
        key = @keys.detect{|k| k.id == value.lookup_key_id }
        name = key.to_s
        element = match.split(LookupKey::EQ_DELM).first
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

  def hashed_class_parameters
    h = {}
    class_parameters.each do |key|
      klass_id = key.environment_classes.first.puppetclass_id
      h[klass_id] ||= []
      h[klass_id] << key
    end
    h
  end

# Generate possible lookup values type matches to a given host
  def path2matches
    matches = []
    possible_value_orders.each do |rule|
      match = []
      Array.wrap(rule).each do |element|
        match << "#{element}#{LookupKey::EQ_DELM}#{attr_to_value(element)}"
      end
      matches << match.join(LookupKey::KEY_DELM)
    end
    matches
  end

  # translates an element such as domain to its real value per host
  # tries to find the host attribute first, parameters and then fallback to a puppet fact.
  def attr_to_value element
    # direct host attribute
    return host.send(element) if host.respond_to?(element)
    # host parameter
    return host.host_params[element] if host.host_params.include?(element)
    # fact attribute
    if (fn = host.fact_names.first(:conditions => { :name => element }))
      return FactValue.where(:host_id => host.id, :fact_name_id => fn.id).first.value
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
