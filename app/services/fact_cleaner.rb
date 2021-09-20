class FactCleaner
  delegate :logger, :to => :Rails

  def initialize(batch_size: 500)
    @batch_size = batch_size
  end

  def clean!
    @deleted_count = 0
    delete_excluded_facts
    delete_orphaned_facts
    self
  end

  def deleted_count
    raise 'cleaner has not cleaned anything yet, run #clean! first' if @deleted_count.nil?

    @deleted_count
  end

  private

  def log_removed(records, message)
    logger.debug("Removed #{records} #{message} records") if records > 0
    records
  end

  def delete_facts_names_values(fact_name_ids)
    log_removed(FactValue.unscoped.where(:fact_name_id => fact_name_ids).delete_all, "associated fact value")
    log_removed(FactName.unscoped.where(:id => fact_name_ids).delete_all, "fact name")
  end

  def delete_orphaned_facts
    delete_leaf_orphaned_facts
    delete_compose_orphaned_facts
    update_leaves
  end

  def delete_leaf_orphaned_facts
    logger.debug "Cleaning leaf orphaned facts"
    valueless_fact_names.leaves.in_batches(of: @batch_size) do |batch|
      @deleted_count += log_removed(batch.delete_all, "fact name")
    end
  end

  def delete_compose_orphaned_facts
    logger.debug "Cleaning compose orphaned facts"

    # Delete the composes with no values or children
    valueless_fact_names.composes.where.not(id: live_ancestors).in_batches(of: @batch_size) do |batch|
      @deleted_count += log_removed(batch.delete_all, "fact name")
    end

    # Delete composes that have no children and only null values
    FactName.composes.reorder(nil).where.not(id: live_ancestors).preload(:fact_values).select(:id).find_in_batches(:batch_size => @batch_size) do |names_batch|
      fact_name_ids = names_batch.select do |fact_name|
        fact_name.fact_values.all? { |fact_value| fact_value.value.nil? }
      end.map(&:id)
      @deleted_count += delete_facts_names_values(fact_name_ids)
    end
  end

  # If you have a value and no descendants, you're a leaf, not a compose!
  def update_leaves
    FactName.composes.where.not(id: live_ancestors).reorder(nil).in_batches(of: @batch_size).update_all(compose: false)
  end

  def delete_excluded_facts
    excluded_facts_regex = FactImporters::Base.excluded_facts_regex
    logger.debug "Cleaning facts matching excluded pattern: #{excluded_facts_regex}"

    FactName.unscoped.reorder(nil).select(:id, :name).find_in_batches(:batch_size => @batch_size) do |names_batch|
      fact_name_ids = names_batch.select { |fact_name| fact_name.name.match(excluded_facts_regex) }.map(&:id)
      @deleted_count += delete_facts_names_values(fact_name_ids)
    end
  end

  def valueless_fact_names
    FactName.where.not(id: FactValue.reorder(nil).distinct.select(:fact_name_id)).reorder(nil)
  end

  def live_ancestors
    return @live_ancestors if @live_ancestors
    @live_ancestors = Set.new
    FactName.leaves.reorder(nil).select(FactName.ancestry_base_class.ancestry_column, :id).find_each(:batch_size => @batch_size) do |leaf|
      @live_ancestors.merge(leaf.ancestor_ids)
    end
    @live_ancestors
  end
end
