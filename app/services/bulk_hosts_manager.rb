class BulkHostsManager
  def initialize(hosts:)
    @hosts = hosts
  end

  def build(reboot: false)
    # returns missed hosts
    @hosts.select do |host|
      success = true
      begin
        host.built(false) if host.build? && host.token_expired?
        host.setBuild
        host.power.reset if reboot && host.supports_power_and_running?
      rescue => error
        Foreman::Logging.exception("Failed to redeploy #{host}.", error)
        success = false
      end
      !success
    end
  end

  def reassign_hostgroups(hostgroup)
    @hosts.each do |host|
      host.hostgroup = hostgroup
      host.save(:validate => false)
    end
  end

  def rebuild_configuration
    # returns a hash with a key/value configuration
    all_fails = {}
    @hosts.each do |host|
      result = host.recreate_config
      result.each_pair do |k, v|
        all_fails[k] ||= []
        all_fails[k] << host unless v
      end
    end
    all_fails
  end

  def change_owner(owner_id)
    @hosts.each do |host|
      host.is_owned_by = owner_id
      host.save(:validate => false)
    end
  end

  def disassociate
    @hosts.each do |host|
      host.disassociate!
    end
  end

  # @param [Boolean] optimistic_import
  #   either fix on mismatch or fail on mismatch
  def assign_taxonomy(taxonomy, optimistic_import)
    tax_type = taxonomy.type.downcase
    if optimistic_import
      @hosts.update_all("#{tax_type}_id".to_sym => taxonomy.id)
      # hosts location needs to be updated before import missing ids
      taxonomy.import_missing_ids
    elsif taxonomy.need_to_be_selected_ids.empty?
      @hosts.update_all("#{tax_type}_id".to_sym => taxonomy.id)
    else
      raise _("Cannot update %{type} to %{name} because of mismatch in settings") % {type: taxonomy.type.downcase, name: taxonomy.name}
    end
  end

  def change_power_state(action)
    failed_hosts = []
    unsupported_hosts = []

    @hosts.each do |host|
      unless host.supports_power?
        unsupported_hosts << {
          id: host.id,
          error: _('Power management not available for this host'),
        }
        next
      end

      begin
        host.power.send(action.to_sym)
      rescue => error
        Foreman::Logging.exception("Failed to set power state for #{host}.", error)
        failed_hosts << {
          id: host.id,
          error: error.message,
        }
      end
    end

    {
      failed_hosts: failed_hosts,
      failed_host_ids: failed_hosts.map { |h| h[:id] },
      unsupported_hosts: unsupported_hosts,
      unsupported_host_ids: unsupported_hosts.map { |h| h[:id] },
    }
  end
end
