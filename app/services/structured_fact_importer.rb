class StructuredFactImporter < FactImporter
  def normalize(facts)
    # Remove empty values first, so nil facts added by normalize_recurse imply compose
    facts = facts.select { |k, v| v.present? }
    normalize_recurse({}, facts)
  end

  # expand {'a' => {'b' => 'c'}} to {'a' => nil, 'a::b' => 'c'}
  def normalize_recurse(memo, facts, prefix = '')
    facts.each do |k, v|
      k = prefix.empty? ? k.to_s : prefix + FactName::SEPARATOR + k.to_s
      if v.is_a?(Hash)
        memo[k] = nil
        normalize_recurse(memo, v, k)
      else
        memo[k] = v.to_s
      end
    end
    memo
  end

  def preload_fact_names
    # Also fetch compose values, generating {NAME => [ID, COMPOSE]}, avoiding loading the entire model
    Hash[fact_name_class.where(:type => fact_name_class).reorder('').pluck(:name, :id, :compose).map { |fact| [fact.shift, fact] }]
  end

  def create_fact_name(fact_names, name, fact_value)
    if name.include?(FactName::SEPARATOR)
      parent_name = /(.*)#{FactName::SEPARATOR}/.match(name)[1]
      parent_fact = create_fact_name(fact_names, parent_name, nil)
    else
      parent_fact = nil
    end

    if fact_names[name]
      fact_name_class.update(fact_names[name][0], :compose => fact_value.nil?) if fact_value.nil? && !fact_names[name][1]
    else
      fact_names[name] = [fact_name_class.create!(:name => name, :compose => fact_value.nil?, :parent_id => parent_fact).id, fact_value.nil?]
    end
    fact_names[name][0]
  end
end
