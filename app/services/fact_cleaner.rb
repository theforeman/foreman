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
    logger.debug "Cleaning leaf orphaned facts"
    leaf_ids = []
    FactName.leaves.includes(:fact_values).reorder(nil).find_in_batches(:batch_size => @batch_size) do |batch|
      fact_name_ids = batch.select { |fact| fact.fact_values.empty? }
      @deleted_count += delete_facts_names_values(fact_name_ids)
      leaf_ids += fact_name_ids
    end

    logger.debug "Cleaning compose orphaned facts"
    FactName.composes.reorder(nil).find_in_batches(:batch_size => @batch_size) do |batch|
      fact_name_ids = batch.select { |compose| compose.descendants.all? { |fact| leaf_ids.include?(fact.id) } }.map(&:id)
      @deleted_count += delete_facts_names_values(fact_name_ids)
    end
  end

  def delete_excluded_facts
    excluded_facts_regex = FactImporter.excluded_facts_regex
    logger.debug "Cleaning facts mathing excluded pattern: #{excluded_facts_regex}"

    FactName.unscoped.reorder(nil).find_in_batches(:batch_size => @batch_size) do |names_batch|
      fact_name_ids = names_batch.select! { |fact_name| fact_name.name.match(excluded_facts_regex) }.map(&:id)
      @deleted_count += delete_facts_names_values(fact_name_ids)
    end
  end
end
