class StructuredFactImporter < FactImporter
  def normalize(facts)
    # Remove empty values first, so nil facts added by flatten_composite imply compose
    facts = facts.select { |k, v| v.present? }
    facts = flatten_composite({}, facts)

    original_keys = facts.keys.to_a
    original_keys.each do |key|
      fill_hierarchy(facts, key)
    end

    facts
  end

  # expand {'a' => {'b' => 'c'}} to {'a' => nil, 'a::b' => 'c'}
  def flatten_composite(memo, facts, prefix = '')
    facts.each do |k, v|
      k = prefix.empty? ? k.to_s : prefix + FactName::SEPARATOR + k.to_s
      if v.is_a?(Hash)
        memo[k] = nil
        flatten_composite(memo, v, k)
      else
        memo[k] = v.to_s
      end
    end
    memo
  end

  # ensures that parent facts already exist in the hash.
  # Example: for fact: "a::b::c", it will make sure that "a" and "a::b" exist in
  # the hash.
  def fill_hierarchy(facts, child_fact_name)
    facts[child_fact_name] = nil unless facts.key?(child_fact_name)

    parent_name = parent_fact_name(child_fact_name)
    fill_hierarchy(facts, parent_name) if parent_name
  end

  def preload_fact_names
    # Also fetch compose values, generating {NAME => [ID, COMPOSE]}, avoiding loading the entire model
    Hash[fact_name_class.where(:type => fact_name_class).reorder('').pluck(:name, :id, :compose).map { |fact| [fact.shift, fact] }]
  end

  def ensure_fact_names
    super

    composite_fact_names = facts.map do |key, value|
      key if value.nil?
    end.compact

    affected_records = fact_name_class.where(:name => composite_fact_names, :compose => false).update_all(:compose => true)

    # reload name records if compose flag was reset.
    initialize_fact_names if affected_records > 0
  end

  def fact_name_attributes(name)
    attributes = super
    fact_value = facts[name]
    parent_fact_record = fact_names[parent_fact_name(name)]

    attributes[:parent] = parent_fact_record
    attributes[:compose] = fact_value.nil?
    attributes
  end

  def parent_fact_name(child_fact_name)
    split = child_fact_name.rindex(FactName::SEPARATOR)
    child_fact_name[0, split]
  end
end
