module Orchestration::DNS
  extend ActiveSupport::Concern

  included do
    after_validation :dns_conflict_detected?, :queue_dns
    before_destroy :queue_dns_destroy
    register_rebuild(:rebuild_dns, N_('DNS'))
  end

  def dns?
    # host.managed? and managed? should always come first so that orchestration doesn't
    # even get tested for such objects
    (host.nil? || host.managed?) && managed? && hostname.present? && ip_available? && !domain.nil? && !domain.proxy.nil? && SETTINGS[:unattended]
  end

  def dns6?
    # host.managed? and managed? should always come first so that orchestration doesn't
    # even get tested for such objects
    (host.nil? || host.managed?) && managed? && hostname.present? && ip6_available? && !domain.nil? && !domain.proxy.nil? && SETTINGS[:unattended]
  end

  def reverse_dns?
    # host.managed? and managed? should always come first so that orchestration doesn't
    # even get tested for such objects
    (host.nil? || host.managed?) && managed? && hostname.present? && ip_available? && !subnet.nil? && subnet.dns? && SETTINGS[:unattended]
  end

  def reverse_dns6?
    # host.managed? and managed? should always come first so that orchestration doesn't
    # even get tested for such objects
    (host.nil? || host.managed?) && managed? && hostname.present? && ip6_available? && !subnet6.nil? && subnet6.dns? && SETTINGS[:unattended]
  end

  def rebuild_dns
    logger.info "IPv4 DNS not supported for #{name}, skipping orchestration rebuild" unless dns?
    logger.info "IPv6 DNS not supported for #{name}, skipping orchestration rebuild" unless dns6?
    logger.info "Reverse IPv4 DNS not supported for #{name}, skipping orchestration rebuild" unless reverse_dns?
    logger.info "Reverse IPv6 DNS not supported for #{name}, skipping orchestration rebuild" unless reverse_dns6?
    return true unless dns? || dns6? || reverse_dns? || reverse_dns6?
    del_dns_a_record_safe
    del_dns_aaaa_record_safe
    del_dns_ptr_record_safe
    del_dns_ptr6_record_safe
    a_record_result = true
    aaaa_record_result = true
    ptr_record_result = true
    ptr6_record_result = true
    begin
      a_record_result = recreate_a_record if dns?
      aaaa_record_result = recreate_aaaa_record if dns6?
      ptr_record_result = recreate_ptr_record if reverse_dns?
      ptr6_record_result = recreate_ptr6_record if reverse_dns6?
      a_record_result && aaaa_record_result && ptr_record_result && ptr6_record_result
    rescue => e
      Foreman::Logging.exception "Failed to rebuild DNS record for #{name}", e, :level => :error
      false
    end
  end

  def dns_a_record
    return unless dns? || @dns_a_record
    return unless ip_available?
    @dns_a_record ||= Net::DNS::ARecord.new dns_a_record_attrs
  end

  def dns_aaaa_record
    return unless dns6? || @dns_aaaa_record
    return unless ip6_available?
    @dns_aaaa_record ||= Net::DNS::AAAARecord.new dns_aaaa_record_attrs
  end

  def dns_ptr_record
    return unless reverse_dns? || @dns_ptr_record
    @dns_ptr_record ||= Net::DNS::PTR4Record.new reverse_dns_record_attrs
  end

  def dns_ptr6_record
    return unless reverse_dns6? || @dns_ptr6_record
    @dns_ptr6_record ||= Net::DNS::PTR6Record.new reverse_dns6_record_attrs
  end

  def del_dns_a_record_safe
    if dns_a_record
      begin
        del_dns_a_record
      rescue => e
        Foreman::Logging.exception "Proxy failed to delete DNS a_record for #{name}, #{ip}", e, :level => :error
      end
    end
  end

  def del_dns_aaaa_record_safe
    if dns_aaaa_record
      begin
        del_dns_aaaa_record
      rescue => e
        Foreman::Logging.exception "Proxy failed to delete DNS aaaa_record for #{name}, #{ip6}", e, :level => :error
      end
    end
  end

  def del_dns_ptr_record_safe
    if dns_ptr_record
      begin
        del_dns_ptr_record
      rescue => e
        Foreman::Logging.exception "Proxy failed to delete DNS IPv4 ptr_record for #{name}, #{ip}", e, :level => :error
      end
    end
  end

  def del_dns_ptr6_record_safe
    if dns_ptr6_record
      begin
        del_dns_ptr6_record
      rescue => e
        Foreman::Logging.exception "Proxy failed to delete DNS IPv6 ptr_record for #{name}, #{ip6}", e, :level => :error
      end
    end
  end

  protected

  def recreate_a_record
    set_dns_a_record unless dns_a_record.nil? || dns_a_record.valid?
  end

  def recreate_aaaa_record
    set_dns_aaaa_record unless dns_aaaa_record.nil? || dns_aaaa_record.valid?
  end

  def recreate_ptr_record
    set_dns_ptr_record unless dns_ptr_record.nil? || dns_ptr_record.valid?
  end

  def recreate_ptr6_record
    set_dns_ptr6_record unless dns_ptr6_record.nil? || dns_ptr6_record.valid?
  end

  def set_dns_a_record
    dns_a_record.create
  end

  def set_dns_aaaa_record
    dns_aaaa_record.create
  end

  def set_conflicting_dns_a_record
    dns_a_record.conflicts.each { |c| c.create }
  end

  def set_conflicting_dns_aaaa_record
    dns_aaaa_record.conflicts.each { |c| c.create }
  end

  def set_dns_ptr_record
    dns_ptr_record.create
  end

  def set_dns_ptr6_record
    dns_ptr6_record.create
  end

  def set_conflicting_dns_ptr_record
    dns_ptr_record.conflicts.each { |c| c.create }
  end

  def set_conflicting_dns_ptr6_record
    dns_ptr6_record.conflicts.each { |c| c.create }
  end

  def del_dns_a_record
    dns_a_record.destroy
  end

  def del_dns_aaaa_record
    dns_aaaa_record.destroy
  end

  def del_conflicting_dns_a_record
    dns_a_record.conflicts.each { |c| c.destroy }
  end

  def del_conflicting_dns_aaaa_record
    dns_aaaa_record.conflicts.each { |c| c.destroy }
  end

  def del_dns_ptr_record
    dns_ptr_record.destroy
  end

  def del_dns_ptr6_record
    dns_ptr6_record.destroy
  end

  def del_conflicting_dns_ptr_record
    dns_ptr_record.conflicts.each { |c| c.destroy }
  end

  def del_conflicting_dns_ptr6_record
    dns_ptr6_record.conflicts.each { |c| c.destroy }
  end

  private

  def dns_a_record_attrs
    { :hostname => hostname, :ip => ip, :resolver => domain.resolver, :proxy => domain.proxy }
  end

  def dns_aaaa_record_attrs
    { :hostname => hostname, :ip => ip6, :resolver => domain.resolver, :proxy => domain.proxy }
  end

  def reverse_dns_record_attrs
    { :hostname => hostname, :ip => ip, :proxy => subnet.dns_proxy }
  end

  def reverse_dns6_record_attrs
    { :hostname => hostname, :ip => ip6, :proxy => subnet6.dns_proxy }
  end

  def queue_dns
    return unless (dns? || dns6? || reverse_dns? || reverse_dns6?) && errors.empty?
    queue_remove_dns_conflicts if overwrite?
    new_record? ? queue_dns_create : queue_dns_update
  end

  def queue_dns_create
    logger.debug "Scheduling new DNS entries"
    queue.create(:name   => _("Create IPv4 DNS record for %s") % self, :priority => 10,
                 :action => [self, :set_dns_a_record]) if dns?
    queue.create(:name   => _("Create Reverse IPv4 DNS record for %s") % self, :priority => 10,
                 :action => [self, :set_dns_ptr_record]) if reverse_dns?
    queue.create(:name   => _("Create IPv6 DNS record for %s") % self, :priority => 10,
                 :action => [self, :set_dns_aaaa_record]) if dns6?
    queue.create(:name   => _("Create Reverse IPv6 DNS record for %s") % self, :priority => 10,
                 :action => [self, :set_dns_ptr6_record]) if reverse_dns6?
  end

  def queue_dns_update
    if old.ip != ip or old.hostname != hostname
      queue.create(:name   => _("Remove IPv4 DNS record for %s") % old, :priority => 9,
                   :action => [old, :del_dns_a_record]) if old.dns?
      queue.create(:name   => _("Remove Reverse IPv4 DNS record for %s") % old, :priority => 9,
                   :action => [old, :del_dns_ptr_record]) if old.reverse_dns?
      queue.create(:name   => _("Remove IPv6 DNS record for %s") % old, :priority => 9,
                   :action => [old, :del_dns_aaaa_record]) if old.dns6?
      queue.create(:name   => _("Remove Reverse IPv6 DNS record for %s") % old, :priority => 9,
                   :action => [old, :del_dns_ptr6_record]) if old.reverse_dns6?
      queue_dns_create
    end
  end

  def queue_dns_destroy
    return unless errors.empty?
    queue.create(:name   => _("Remove IPv4 DNS record for %s") % self, :priority => 1,
                 :action => [self, :del_dns_a_record]) if dns?
    queue.create(:name   => _("Remove Reverse IPv4 DNS record for %s") % self, :priority => 1,
                 :action => [self, :del_dns_ptr_record]) if reverse_dns?
    queue.create(:name   => _("Remove IPv6 DNS record for %s") % self, :priority => 1,
                 :action => [self, :del_dns_aaaa_record]) if dns6?
    queue.create(:name   => _("Remove Reverse IPv6 DNS record for %s") % self, :priority => 1,
                 :action => [self, :del_dns_ptr6_record]) if reverse_dns6?
  end

  def queue_remove_dns_conflicts
    return unless errors.empty?
    return unless overwrite?
    logger.debug "Scheduling DNS conflict removal"
    queue.create(:name   => _("Remove conflicting IPv4 DNS record for %s") % self, :priority => 0,
                 :action => [self, :del_conflicting_dns_a_record]) if dns? and dns_a_record and dns_a_record.conflicting?
    queue.create(:name   => _("Remove conflicting Reverse IPv4 DNS record for %s") % self, :priority => 0,
                 :action => [self, :del_conflicting_dns_ptr_record]) if reverse_dns? and dns_ptr_record and dns_ptr_record.conflicting?
    queue.create(:name   => _("Remove conflicting IPv6 DNS record for %s") % self, :priority => 0,
                 :action => [self, :del_conflicting_dns_aaaa_record]) if dns6? and dns_aaaa_record and dns_aaaa_record.conflicting?
    queue.create(:name   => _("Remove conflicting Reverse IPv6 DNS record for %s") % self, :priority => 0,
                 :action => [self, :del_conflicting_dns_ptr6_record]) if reverse_dns6? and dns_ptr6_record and dns_ptr6_record.conflicting?
  end

  def dns_conflict_detected?
    return false if ip.blank? or hostname.blank?
    # can't validate anything if dont have an ip-address yet
    return false unless require_ip4_validation? || require_ip6_validation?
    # we should only alert on conflicts if overwrite mode is off
    return false if overwrite?

    status = true
    status = failure(_("DNS A Records %s already exists") % dns_a_record.conflicts.to_sentence, nil, :conflict) if dns? and dns_a_record and dns_a_record.conflicting?
    status = failure(_("DNS AAAA Records %s already exists") % dns_aaaa_record.conflicts.to_sentence, nil, :conflict) if dns6? and dns_aaaa_record and dns_aaaa_record.conflicting?
    status = failure(_("DNS IPv4 PTR Records %s already exists") % dns_ptr_record.conflicts.to_sentence, nil, :conflict) if reverse_dns? and dns_ptr_record and dns_ptr_record.conflicting?
    status = failure(_("DNS IPv6 PTR Records %s already exists") % dns_ptr6_record.conflicts.to_sentence, nil, :conflict) if reverse_dns6? and dns_ptr6_record and dns_ptr6_record.conflicting?
    not status #failure method returns 'false'
  rescue Net::Error => e
    if domain.nameservers.empty?
      failure(_("Error connecting to system DNS server(s) - check /etc/resolv.conf"), e)
    else
      failure(_("Error connecting to '%{domain}' domain DNS servers: %{servers} - check query_local_nameservers and dns_conflict_timeout settings") % {:domain => domain.try(:name), :servers => domain.nameservers.join(',')}, e)
    end
  end
end
