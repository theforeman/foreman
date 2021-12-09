module Orchestration::DNS
  extend ActiveSupport::Concern
  include Orchestration::Common

  included do
    after_validation :dns_conflict_detected?, :unless => :skip_orchestration?
    after_validation :queue_dns
    before_destroy :queue_dns_destroy
    register_rebuild(:rebuild_dns, N_('DNS'))
  end

  def dns_ready?
    # host.managed? and managed? should always come first so that orchestration doesn't
    # even get tested for such objects
    (host.nil? || host.managed?) && managed? && hostname.present?
  end

  def dns?
    dns_ready? && ip_available? && domain.present? && domain.proxy.present?
  end

  def dns6?
    dns_ready? && ip6_available? && domain.present? && domain.proxy.present?
  end

  def reverse_dns?
    dns_ready? && ip_available? && subnet.present? && subnet.dns?
  end

  def reverse_dns6?
    dns_ready? && ip6_available? && subnet6.present? && subnet6.dns?
  end

  def rebuild_dns
    feasible = {}
    DnsInterface::RECORD_TYPES.each do |record_type|
      feasible[record_type] = dns_feasible?(record_type)
      logger.info "DNS record type #{record_type} not supported for #{name}, skipping orchestration rebuild" unless feasible[record_type]
    end
    return true unless feasible.any?

    results = {}

    DnsInterface::RECORD_TYPES.each do |record_type|
      del_dns_record_safe(record_type)

      begin
        results[record_type] = dns_feasible?(record_type) ? recreate_dns_record(record_type) : true
      rescue => e
        Foreman::Logging.exception "Failed to rebuild DNS record for #{name}(#{ip}/#{ip6})", e, :level => :error
        return false
      end
    end
    results.values.all?
  end

  def queue_dns
    return log_orchestration_errors unless (dns? || dns6? || reverse_dns? || reverse_dns6? || old&.dns? || old&.dns6? || old&.reverse_dns? || old&.reverse_dns6?) && errors.empty?
    queue_remove_dns_conflicts if overwrite?
    new_record? ? queue_dns_create : queue_dns_update
  end

  def queue_dns_create
    logger.debug "Scheduling new DNS entries"
    DnsInterface::RECORD_TYPES.each do |record_type|
      if dns_feasible?(record_type)
        queue.create(:name   => _("Create %{type} for %{host}") % {:host => self, :type => dns_class(record_type).human}, :priority => 10,
                     :action => [self, :set_dns_record, record_type])
      end
    end
  end

  def queue_dns_update
    return unless pending_dns_record_changes?
    DnsInterface::RECORD_TYPES.each do |record_type|
      if old.dns_feasible?(record_type)
        queue.create(:name   => _("Remove %{type} for %{host}") % {:host => old, :type => dns_class(record_type).human }, :priority => 9,
                     :action => [old, :del_dns_record, record_type])
      end
    end
    queue_dns_create
  end

  def queue_dns_destroy
    return unless errors.empty?
    DnsInterface::RECORD_TYPES.each do |record_type|
      if dns_feasible?(record_type)
        queue.create(:name   => _("Remove %{type} for %{host}") % {:host => self, :type => dns_class(record_type).human}, :priority => 1,
                     :action => [self, :del_dns_record, record_type])
      end
    end
  end

  def queue_remove_dns_conflicts
    return unless errors.empty?
    return unless overwrite?
    logger.debug "Scheduling DNS conflict removal"
    DnsInterface::RECORD_TYPES.each do |record_type|
      if dns_feasible?(record_type) && dns_record(record_type) && dns_record(record_type).conflicting?
        queue.create(:name   => _("Remove conflicting %{type} for %{host}") % {:host => self, :type => dns_class(record_type).human}, :priority => 0,
                     :action => [self, :del_conflicting_dns_record, record_type])
      end
    end
  end

  def pending_dns_record_changes?
    !attr_equivalent?(old.ip, ip) || !attr_equivalent?(old.ip6, ip6) || !attr_equivalent?(old.hostname, hostname)
  end

  def dns_conflict_detected?
    return false if ip.blank? || hostname.blank?
    # can't validate anything if dont have an ip-address yet
    return false unless require_ip4_validation? || require_ip6_validation?
    # we should only alert on conflicts if overwrite mode is off
    return false if overwrite?

    status = true
    DnsInterface::RECORD_TYPES.each do |record_type|
      if dns_feasible?(record_type) && dns_record(record_type) && dns_record(record_type).conflicting?
        conflicts = dns_record(record_type).conflicts
        status = failure(_("%{type} %{conflicts} already exists") % {:conflicts => conflicts.to_sentence, :type => dns_class(record_type).human(conflicts.count)}, nil, :conflict)
      end
    end
    !status # failure method returns 'false'
  rescue Resolv::ResolvTimeout, Net::Error => e
    if domain.nameservers.empty?
      failure(_("Error connecting to system DNS server(s) - check /etc/resolv.conf"), e)
    else
      failure(_("Error connecting to '%{domain}' domain DNS servers: %{servers} - check query_local_nameservers and dns_timeout settings") % {:domain => domain.try(:name), :servers => domain.nameservers.join(',')}, e)
    end
  end
end
