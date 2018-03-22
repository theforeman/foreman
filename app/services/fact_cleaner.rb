class FactCleaner
  delegate :logger, :to => :Rails

  def clean!
    @deleted_count = delete_excluded_facts + delete_orphaned_facts
    self
  end

  def deleted_count
    raise 'cleaner has not cleaned anything yet, run #clean! first' if @deleted_count.nil?
    @deleted_count
  end

  private

  def delete_orphaned_facts
    to_delete = find_leaf_orphaned_facts
    # we also delete all composes that either don't have any descendant or all of them are to be deleted
    to_delete += find_compose_orphaned_facts(to_delete)
    delete!(to_delete)
    to_delete.uniq.count
  end

  def find_leaf_orphaned_facts
    result = []
    logger.debug "Searching for leaf orphaned facts..."
    FactName.leaves.includes(:fact_values).find_in_batches do |batch|
      result += batch.select do |fact|
        fact.fact_values.empty?
      end
    end
    result
  end

  def find_compose_orphaned_facts(found)
    logger.debug "Searching for compose orphaned facts..."
    FactName.composes.find_in_batches do |batch|
      found += batch.select do |compose|
        compose.descendants.all? { |fact| found.include?(fact) }
      end
    end
    found
  end

  def delete!(to_delete)
    logger.debug "#{to_delete.size} facts will be removed"
    to_delete.each do |fact|
      logger.debug { "Removing fact #{fact}" }
      fact.destroy
    end
    logger.debug "Cleanup of facts finished!"
  end

  def find_excluded_facts
    logger.debug "Searching for facts that match excluded pattern..."
    fact_name_ids = []

    excluded_facts_regex = FactImporter.excluded_facts_regex

    FactName.unscoped.find_in_batches(:batch_size => 100) do |names_batch|
      names_batch.select! { |fact_name| fact_name.name.match(excluded_facts_regex) }
      fact_name_ids += names_batch.map(&:id)
    end

    fact_name_ids.uniq
  end

  def delete_excluded_facts
    fact_names = find_excluded_facts

    # delete related fact values first
    logger.debug "Removing values of excluded facts..."
    deleted_values = FactValue.unscoped.where(:fact_name_id => fact_names).delete_all
    logger.debug "Removed #{deleted_values} associated fact value records."
    logger.debug "Removing excluded fact names..."
    deleted_names = FactName.unscoped.where(:id => fact_names).delete_all
    logger.debug "Removed #{deleted_names} fact name records."
    deleted_names
  end
end
