class InterfaceCleaner
  include ActiveRecord::Sanitization

  ESCAPE_CHAR = '\\'

  def self.nic_pattern_to_like(nic)
    sanitize_sql_like(nic, ESCAPE_CHAR).tr('*', '%')
  end

  def self.ignored_interface_like_patterns
    Setting[:ignored_interface_identifiers].map { |pattern| nic_pattern_to_like(pattern) }
  end

  delegate :logger, :to => :Rails

  attr_reader :primary_nics, :provision_nics, :primary_hosts, :provision_hosts

  def clean!
    @deleted_count = delete_excluded_nics

    @primary_nics, @primary_hosts = excluded_nics.where(primary: true).pluck(:id, :host_id).transpose
    @provision_nics, @provision_hosts = excluded_nics.where(provision: true).pluck(:id, :host_id).transpose
    self
  end

  def deleted_count
    raise 'cleaner has not cleaned anything yet, run #clean! first' if @deleted_count.nil?
    @deleted_count
  end

  private

  def excluded_nics
    ignored_nic_patterns = InterfaceCleaner.ignored_interface_like_patterns

    arel = Nic::Base.arel_table
    chained_or = arel[:identifier].matches_any(ignored_nic_patterns, ESCAPE_CHAR, true)

    Nic::Base.where(chained_or)
  end

  def delete_excluded_nics
    nics = excluded_nics.where(primary: false, provision: false)

    logger.debug "Removing excluded nics..."
    deleted_nics = nics.delete_all
    logger.debug "Removed #{deleted_nics} nic records."
    deleted_nics
  end
end
