module Orchestration::DNS
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      after_validation :validate_dns, :queue_remove_dns_conflicts, :queue_dns
      before_destroy :queue_dns_destroy
    end
  end

  module InstanceMethods

    def dns?
      !domain.nil? and !domain.proxy.nil?
    end

    def dns_a_record
      return unless dns? or @dns_a_record
      @dns_a_record ||= Net::DNS::ARecord.new dns_record_attrs
    end

    def dns_ptr_record
      return unless dns? or @dns_ptr_record
      @dns_ptr_record ||= Net::DNS::PTRRecord.new dns_record_attrs
    end

    protected

    def set_dns_a_record
      dns_a_record.create
    end

    def set_conflicting_dns_a_record
      dns_a_record.conflicts[0].create
    end

    def set_dns_ptr_record
      dns_ptr_record.create
    end

    def set_conflicting_dns_ptr_record
      dns_ptr_record.conflicts[0].create
    end

    def del_dns_a_record
      dns_a_record.destroy
    end

    def del_conflicting_dns_a_record
      dns_a_record.conflicts[0].destroy
    end

    def del_dns_ptr_record
      dns_ptr_record.destroy
    end

    def del_conflicting_dns_ptr_record
      dns_ptr_record.conflicts[0].destroy
    end

    def validate_dns
      return unless dns?
      return unless new_record?
      return if overwrite?
      status = true
      status = failure("- #{dns_a_record.conflicts[0]} exists in DNS ", nil, :conflict) if dns_a_record.conflicting?
      status &= failure("- #{dns_ptr_record.conflicts[0]} exists in DNS", nil, :conflict) if dns_ptr_record.conflicting?
    end

    def dns_record_attrs
      { :hostname => name, :ip => ip, :resolver => domain.resolver, :proxy => domain.proxy }
    end

    private

    def queue_dns
      return unless dns? and errors.empty?
      new_record? ? queue_dns_create : queue_dns_update
    end

    def queue_dns_create
      logger.debug "Scheduling new DNS entries"
      queue.create(:name   => "DNS record for #{self}", :priority => 3,
                   :action => [self, :set_dns_a_record])
      queue.create(:name   => "Reverse DNS record for #{self}", :priority => 3,
                   :action => [self, :set_dns_ptr_record])
    end

    def queue_dns_update
      if old.ip != ip or old.name != name
        if old.dns?
          queue.create(:name   => "Remove DNS record for #{old}", :priority => 1,
                       :action => [old, :del_dns_a_record])
          queue.create(:name   => "Remove Reverse DNS record for #{old}", :priority => 1,
                       :action => [old, :del_dns_ptr_record])
        end
        queue_dns_create
      end
    end

    def queue_dns_destroy
      return unless dns? and errors.empty?
      queue.create(:name   => "Remove DNS record for #{self}", :priority => 1,
                   :action => [self, :del_dns_a_record])
      queue.create(:name   => "Remove Reverse DNS record for #{self}", :priority => 1,
                   :action => [self, :del_dns_ptr_record])
    end

    def queue_remove_dns_conflicts
      return unless dns? and errors.empty?
      return unless overwrite?
      logger.debug "Scheduling DNS conflict removal"
      queue.create(:name   => "Remove conflicting DNS record for #{self}", :priority => 1,
                   :action => [self, :del_conflicting_dns_a_record])
      queue.create(:name   => "Remove conflicting Reverse DNS record for #{self}", :priority => 1,
                   :action => [self, :del_conflicting_dns_ptr_record])

    end
  end
end
