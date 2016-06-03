module Orchestration::DNS
  extend ActiveSupport::Concern
  include Orchestration::Common

  included do
    after_validation :dns_conflict_detected?, :queue_dns, :unless => :importing_facts
    before_destroy :queue_dns_destroy, :unless => :importing_facts
    register_rebuild(:rebuild_dns, N_('DNS'))
  end

  def dns?
    # host.managed? and managed? should always come first so that orchestration doesn't
    # even get tested for such objects
    (host.nil? || host.managed?) && managed? && hostname.present? && ip_available? && !domain.nil? && !domain.proxy.nil? && SETTINGS[:unattended]
  end

  def reverse_dns?
    # host.managed? and managed? should always come first so that orchestration doesn't
    # even get tested for such objects
    (host.nil? || host.managed?) && managed? && hostname.present? && ip_available? && !subnet.nil? && subnet.dns? && SETTINGS[:unattended]
  end

  def rebuild_dns
    logger.info "DNS not supported for #{name}, #{ip}, skipping orchestration rebuild" unless dns?
    logger.info "Reverse DNS not supported for #{name}, #{ip}, skipping orchestration rebuild" unless reverse_dns?
    return true unless dns? || reverse_dns?
    del_dns_a_record_safe
    del_dns_ptr_record_safe
    a_record_result, ptr_record_result = true, true
    begin
      a_record_result = recreate_a_record if dns?
      ptr_record_result = recreate_ptr_record if reverse_dns?
      a_record_result && ptr_record_result
    rescue => e
      Foreman::Logging.exception "Failed to rebuild DNS record for #{name}, #{ip}", e, :level => :error
      false
    end
  end

  def dns_a_record
    return unless dns? or @dns_a_record
    handle_validation_errors do
      @dns_a_record ||= Net::DNS::ARecord.new dns_record_attrs
    end
  end

  def dns_ptr_record
    return unless reverse_dns? or @dns_ptr_record
    handle_validation_errors do
      @dns_ptr_record ||= Net::DNS::PTR4Record.new reverse_dns_record_attrs
    end
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

  def del_dns_ptr_record_safe
    if dns_ptr_record
      begin
        del_dns_ptr_record
      rescue => e
        Foreman::Logging.exception "Proxy failed to delete DNS ptr_record for #{name}, #{ip}", e, :level => :error
      end
    end
  end

  protected

  def recreate_a_record
    set_dns_a_record unless dns_a_record.nil? || dns_a_record.valid?
  end

  def recreate_ptr_record
    set_dns_ptr_record unless dns_ptr_record.nil? || dns_ptr_record.valid?
  end

  def set_dns_a_record
    dns_a_record.create
  end

  def set_conflicting_dns_a_record
    dns_a_record.conflicts.each { |c| c.create }
  end

  def set_dns_ptr_record
    dns_ptr_record.create
  end

  def set_conflicting_dns_ptr_record
    dns_ptr_record.conflicts.each { |c| c.create }
  end

  def del_dns_a_record
    dns_a_record.destroy
  end

  def del_conflicting_dns_a_record
    dns_a_record.conflicts.each { |c| c.destroy }
  end

  def del_dns_ptr_record
    dns_ptr_record.destroy
  end

  def del_conflicting_dns_ptr_record
    dns_ptr_record.conflicts.each { |c| c.destroy }
  end

  private

  def dns_record_attrs
    { :hostname => hostname, :ip => ip, :resolver => domain.resolver, :proxy => domain.proxy }
  end

  def reverse_dns_record_attrs
    { :hostname => hostname, :ip => ip, :proxy => subnet.dns_proxy }
  end

  def queue_dns
    return unless (dns? or reverse_dns?) and errors.empty?
    queue_remove_dns_conflicts if overwrite?
    new_record? ? queue_dns_create : queue_dns_update
  end

  def queue_dns_create
    logger.debug "Scheduling new DNS entries"
    queue.create(:name   => _("Create DNS record for %s") % self, :priority => 10,
                 :action => [self, :set_dns_a_record]) if dns?
    queue.create(:name   => _("Create Reverse DNS record for %s") % self, :priority => 10,
                 :action => [self, :set_dns_ptr_record]) if reverse_dns?
  end

  def queue_dns_update
    if old.ip != ip or old.hostname != hostname
      queue.create(:name   => _("Remove DNS record for %s") % old, :priority => 9,
                   :action => [old, :del_dns_a_record]) if old.dns?
      queue.create(:name   => _("Remove Reverse DNS record for %s") % old, :priority => 9,
                   :action => [old, :del_dns_ptr_record]) if old.reverse_dns?
      queue_dns_create
    end
  end

  def queue_dns_destroy
    return unless errors.empty?
    queue.create(:name   => _("Remove DNS record for %s") % self, :priority => 1,
                 :action => [self, :del_dns_a_record]) if dns?
    queue.create(:name   => _("Remove Reverse DNS record for %s") % self, :priority => 1,
                 :action => [self, :del_dns_ptr_record]) if reverse_dns?
  end

  def queue_remove_dns_conflicts
    return unless errors.empty?
    return unless overwrite?
    logger.debug "Scheduling DNS conflict removal"
    queue.create(:name   => _("Remove conflicting DNS record for %s") % self, :priority => 0,
                 :action => [self, :del_conflicting_dns_a_record]) if dns? and dns_a_record and dns_a_record.conflicting?
    queue.create(:name   => _("Remove conflicting Reverse DNS record for %s") % self, :priority => 0,
                 :action => [self, :del_conflicting_dns_ptr_record]) if reverse_dns? and dns_ptr_record and dns_ptr_record.conflicting?
  end

  def dns_conflict_detected?
    return false if ip.blank? or hostname.blank?
    # can't validate anything if dont have an ip-address yet
    return false unless require_ip_validation?
    # we should only alert on conflicts if overwrite mode is off
    return false if overwrite?

    status = true
    status = failure(_("DNS A Records %s already exists") % dns_a_record.conflicts.to_sentence, nil, :conflict) if dns? and dns_a_record and dns_a_record.conflicting?
    status = failure(_("DNS PTR Records %s already exists") % dns_ptr_record.conflicts.to_sentence, nil, :conflict) if reverse_dns? and dns_ptr_record and dns_ptr_record.conflicting?
    !status #failure method returns 'false'
  rescue Net::Error => e
    if domain.nameservers.empty?
      failure(_("Error connecting to system DNS server(s) - check /etc/resolv.conf"), e)
    else
      failure(_("Error connecting to '%{domain}' domain DNS servers: %{servers} - check query_local_nameservers and dns_conflict_timeout settings") % {:domain => domain.try(:name), :servers => domain.nameservers.join(',')}, e)
    end
  end
end
