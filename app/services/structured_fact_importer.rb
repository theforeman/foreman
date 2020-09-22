class StructuredFactImporter < FactImporter
  include ActionView::Helpers::NumberHelper

  MAXIMUM_FLAT_FACTS = /^(blockdevice_|ipaddress6?_|macaddress_|mtu_|speed_|auto_negotiation_|duplex_|link_|wol_)/

  def normalize(facts)
    max = Setting[:maximum_structured_facts]
    flat_counts = {}
    dropped = 0
    # Remove empty values first, so nil facts added by flatten_composite imply compose
    # and count flat counts for later removal and also directly remove too large sub-hashes
    facts.delete_if do |k, v|
      match = k.to_s.match(MAXIMUM_FLAT_FACTS)
      if match
        flat_counts[match.captures.first] ||= 0
        flat_counts[match.captures.first] += 1
      end
      v.nil? || (v.is_a?(String) && v.empty?) || ((v.is_a?(Hash) || v.is_a?(Array)) && v.count > max && (dropped += v.count))
    end

    # Remove flat facts exceeding the limit
    flat_counts.each_pair do |string, count|
      if count > max
        facts.delete_if { |k, v| k.to_s.start_with?(string) && (dropped += 1) }
      end
    end

    # Report rough precision of number of dropped facts so it does not change often (e.g. "10 Thousand")
    if dropped > 0
      facts['foreman'] ||= {}
      facts['foreman']['dropped_subtree_facts'] = number_to_human(dropped, precision: 1)
      logger.warn "Some subtrees exceeded #{max} limit of facts, dropped #{dropped} keys"
    end

    facts = flatten_composite({}, facts)

    original_keys = facts.keys.to_a
    original_keys.each do |key|
      fill_hierarchy(facts, key)
    end

    facts
  end

  # expand {'a' => {'b' => 'c'}} to {'a::b' => 'c'}
  def flatten_composite(memo, facts, prefix = '')
    facts.each do |k, v|
      k = prefix.empty? ? k.to_s : prefix + FactName::SEPARATOR + k.to_s

      # skip fact if it is excluded
      next if k.match(excluded_facts)

      if v.is_a?(Hash)
        # skip recursion if current key is excluded. Example:
        # given excluded_facts = macvtap.*, and fact hash: interfaces => macvtap01 => ip => 1.2.3.4
        # do not create nodes that start with: "interfaces::macvtap01"
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

    # Performance/ChainArrayAllocation
    composite_fact_names = facts.map do |key, value|
      key if value.nil?
    end
    composite_fact_names.compact!

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
    return nil unless split
    child_fact_name[0, split]
  end
end
