class PuppetFactImporter
  attr_reader :host, :facts

  def initialize(host, facts = {})
    @host = host
    @facts = normalize_facts(facts)
  end

    # expect a facts hash
  def importFacts
    # we are not importing facts for hosts in build state (e.g. waiting for a re-installation)
    raise ::Foreman::Exception.new("Host is pending for Build") if host.build
    time = facts[:_timestamp]
    time = time.to_time if time.is_a?(String)

    # we are not doing anything we already processed this fact (or a newer one)
    if time
      return true unless host.last_compile.nil? or (host.last_compile + 1.minute < time)
      host.last_compile = time
    end
    # save all other facts
    merge_facts
  end

  # Inspired from Puppet::Rails:Host
  def merge_facts
    delete_removed_facts

    db_facts = host.fact_values.includes(:fact_name).index_by(&:name)
    add_new_facts(facts.keys - db_facts.keys)
    update_facts(facts.keys & db_facts.keys, db_facts)

    Rails.logger.debug("Merging facts for '#{host.name}' completed. Total #{FactValue.where(:host_id => host).count} facts")
  end

  def delete_removed_facts
    count_before = FactValue.where(:host_id => host).count

    FactValue.delete_all([
        "fact_name_id in (select id from fact_names where name not in (?)) and host_id=?",
        facts.keys, host.id
    ])

    Rails.logger.debug("Merging facts for '#{host.name}': deleted #{count_before-FactValue.where(:host_id => host).count} facts")
  end

  def add_new_facts(facts_to_create)
    fact_names = FactName.maximum(:id, :group => 'name')
    facts_to_create.each do |name|
      host.fact_values.build(:value => facts[name],
        :fact_name_id => fact_names[name] || FactName.create!(:name => name).id)
    end

    Rails.logger.debug("Merging facts for '#{host.name}': added #{facts_to_create.size} facts")
  end

  def update_facts(facts_to_update, db_facts)
    FactValue.update(
        facts_to_update.collect { |name| db_facts[name].id },
        facts_to_update.collect { |name| { :value => facts[name] } }
    )
    Rails.logger.debug("Merging facts for '#{host.name}': updated #{facts_to_update.size} facts")
  end

  def normalize_facts(to_normalize)
    to_normalize.inject({}) do |hash, fact|
      name, value = *fact
      value.blank? ? hash : hash.update(name.to_s => value.to_s)
    end
  end
end
