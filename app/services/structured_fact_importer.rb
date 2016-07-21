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

  def find_or_create_fact_name(name, value = nil)
    if name.include?(FactName::SEPARATOR)
      parent_name = /(.*)#{FactName::SEPARATOR}/.match(name)[1]
      parent_fact = find_or_create_fact_name(parent_name, nil)
      fact_name = parent_fact.children.where(:name => name, :type => fact_name_class.to_s).first
    else
      parent_fact = nil
      fact_name = fact_name_class.where(:name => name, :type => fact_name_class.to_s).first
    end

    if fact_name
      fact_name.update_attribute(:compose, value.nil?) if value.nil? && !fact_name.compose?
    else
      fact_name = fact_name_class.create!(:name => name, :type => fact_name_class.to_s, :compose => value.nil?, :parent => parent_fact)
    end
    fact_name
  end
end
