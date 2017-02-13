class FactCleaner
  delegate :logger, :to => :Rails

  def clean!
    to_delete = find_leaf_orphaned_facts
    # we also delete all composes that either don't have any descendant or all of them are to be deleted
    to_delete += find_compose_orphaned_facts(to_delete)
    delete!(to_delete)
    @deleted_count = to_delete.count
    self
  end

  def deleted_count
    raise 'cleaner has not cleaned anything yet, run #clean! first' if @deleted_count.nil?
    @deleted_count
  end

  private

  def find_leaf_orphaned_facts
    result = []
    logger.info "Searching for leaf orphaned facts..."
    FactName.leaves.includes(:fact_values).find_in_batches do |batch|
      result += batch.select do |fact|
        fact.fact_values.empty?
      end
    end
    result
  end

  def find_compose_orphaned_facts(found)
    logger.info "Searching for compose orphaned facts..."
    FactName.composes.find_in_batches do |batch|
      found += batch.select do |compose|
        compose.descendants.all? { |fact| found.include?(fact) }
      end
    end
    found
  end

  def delete!(to_delete)
    logger.info "#{to_delete.size} facts will be removed"
    to_delete.each do |fact|
      logger.debug { "Removing fact #{fact}" }
      fact.destroy
    end
    logger.info "Cleanup of facts finished!"
  end
end
