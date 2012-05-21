module Orchestration::DNS
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      after_validation :queue_dns
      before_destroy :queue_dns_destroy
    end
  end

  module InstanceMethods

    def dns?
      !domain.nil? and !domain.proxy.nil? and managed?
    end

    def reverse_dns?
      !subnet.nil? and !subnet.dns_proxy.nil? and managed?
    end

    def dns_a_record
      return unless dns? or @dns_a_record
      @dns_a_record ||= Net::DNS::ARecord.new dns_record_attrs
    end

    def dns_ptr_record
      return unless reverse_dns? or @dns_ptr_record
      @dns_ptr_record ||= Net::DNS::PTRRecord.new reverse_dns_record_attrs
    end

    protected

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
      { :hostname => name, :ip => ip, :resolver => domain.resolver, :proxy => domain.proxy }
    end

    def reverse_dns_record_attrs
      { :hostname => name, :ip => ip, :proxy => subnet.dns_proxy }
    end

    def queue_dns
      return unless (dns? or reverse_dns?) and errors.empty?
      queue_remove_dns_conflicts if dns_conflict_detected?
      new_record? ? queue_dns_create : queue_dns_update
    end

    def queue_dns_create
      logger.debug "Scheduling new DNS entries"
      queue.create(:name   => "Create DNS record for #{self}", :priority => 10,
                   :action => [self, :set_dns_a_record])
      queue.create(:name   => "Create Reverse DNS record for #{self}", :priority => 10,
                   :action => [self, :set_dns_ptr_record]) if reverse_dns?
    end

    def queue_dns_update
      if old.ip != ip or old.name != name
        queue.create(:name   => "Remove DNS record for #{old}", :priority => 10,
                     :action => [old, :del_dns_a_record]) if old.dns?
        queue.create(:name   => "Remove Reverse DNS record for #{old}", :priority => 10,
                     :action => [old, :del_dns_ptr_record]) if old.reverse_dns?
        queue_dns_create
      end
    end

    def queue_dns_destroy
      return unless errors.empty?
      queue.create(:name   => "Remove DNS record for #{self}", :priority => 1,
                   :action => [self, :del_dns_a_record]) if dns?
      queue.create(:name   => "Remove Reverse DNS record for #{self}", :priority => 1,
                   :action => [self, :del_dns_ptr_record]) if reverse_dns?
    end

    def queue_remove_dns_conflicts
      return unless errors.empty?
      return unless overwrite?
      logger.debug "Scheduling DNS conflict removal"
      queue.create(:name   => "Remove conflicting DNS record for #{self}", :priority => 1,
                   :action => [self, :del_conflicting_dns_a_record]) if dns? and dns_a_record and dns_a_record.conflicting?
      queue.create(:name   => "Remove conflicting Reverse DNS record for #{self}", :priority => 1,
                   :action => [self, :del_conflicting_dns_ptr_record]) if reverse_dns? and dns_ptr_record and dns_ptr_record.conflicting?

    end

    def dns_conflict_detected?
      return false unless ip.present? or name.present? or dns?
      return false unless require_ip_validation?
      return false if overwrite?
      status = true
      status = failure("DNS A Record #{dns_a_record.conflicts[0]} already exists", nil, :conflict) if dns? and dns_a_record.conflicting?
      status &= failure("DNS PTR Record #{dns_ptr_record.conflicts[0]} already exists", nil, :conflict) if reverse_dns? and dns_ptr_record.conflicting?
      status
    end

  end
end
