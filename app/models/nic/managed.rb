module Nic
  class Managed < Interface
    include Orchestration
    include Orchestration::DHCP
    include Orchestration::DNS
    include Orchestration::TFTP
    include Orchestration::ExternalIPAM
    include DnsInterface
    include InterfaceCloning

    include Exportable

    before_validation :set_provisioning_flag
    after_save :update_lookup_value_fqdn_matchers, :drop_host_cache

    validates :ip, :belongs_to_subnet => {:subnet => :subnet }, :if => ->(nic) { nic.managed? }
    validates :ip6, :belongs_to_subnet => {:subnet => :subnet6 }, :if => ->(nic) { nic.managed? }

    validates :compute_resource, :belongs_to_host_taxonomy => { :taxonomy => :organization },
              :if => ->(nic) { nic.host.respond_to?(:compute_resource) }
    validates :compute_resource, :belongs_to_host_taxonomy => { :taxonomy => :location },
              :if => ->(nic) { nic.host.respond_to?(:compute_resource) }

    # Interface normally are not executed by them self, so we use the host queue and related methods.
    # this ensures our orchestration works on both a host and a managed interface
    delegate :capabilities, :compute_resource, :operatingsystem, :provisioning_template, :jumpstart?, :build, :build?, :os, :arch,
      :image_build?, :pxe_build?, :pxe_build?, :token, :model, :to => :host
    delegate :operatingsystem_id, :hostgroup_id, :overwrite?,
      :skip_orchestration?, :skip_orchestration!, :to => :host, :allow_nil => true

    attr_exportable :ip, :ip6, :mac, :name, :attrs, :virtual, :link, :identifier, :managed,
      :primary, :provision, :subnet, :subnet6,
      :tag => ->(nic) { nic.tag if nic.virtual? },
      :attached_to => ->(nic) { nic.attached_to if nic.virtual? },
      :type => ->(nic) { nic.type.constantize.humanized_name }

    # this ensures we can create an interface even when there is no host queue
    # e.g. outside to Host nested attributes
    def queue
      if host&.respond_to?(:queue)
        host.queue
      else
        super
      end
    end

    def progress_report_id
      if host&.respond_to?(:progress_report_id)
        host.progress_report_id
      else
        super
      end
    end

    def progress_report_id=(value)
      if host&.respond_to?(:progress_report_id=)
        host.progress_report_id = value
      else
        super
      end
    end

    def self.humanized_name
      N_('Interface')
    end

    def ip_available?
      ip.present? || compute_provides_ip?(:ip)
    end

    def ip6_available?
      ip6.present? || compute_provides_ip?(:ip6)
    end

    def mac_available?
      mac_addresses_for_provisioning.any? || (host.present? && host.compute_provides?(:mac))
    end

    protected

    def copy_hostname_from_host
      self.name = host.read_attribute :name
    end

    def set_provisioning_flag
      return unless primary?
      return unless host.present?
      self.provision = true if host.interfaces.detect(&:provision).nil?
    end

    def update_lookup_value_fqdn_matchers
      return unless primary?
      return unless saved_change_to_fqdn?
      return unless host.present?
      LookupValue.where(:match => "fqdn=#{fqdn_before_last_save}").
        update_all(:match => host.lookup_value_match)
    end

    def drop_host_cache
      return unless host.present?
      host.drop_primary_interface_cache   if primary?
      host.drop_provision_interface_cache if provision?
      true
    end

    # log errors to host object since we can't read it later (even if host.destroy fails host.interfaces is
    # always set to [] so we lose interfaces errors)
    def failure(msg, exception_or_backtrace = nil, dest = :base)
      result = super
      host.errors.add(dest, msg)
      result
    end

    # we must also clone host object so we can detect host attributes changes
    def setup_clone
      return if new_record?
      @old = super
      @old.host = host.setup_clone
      @old
    end
  end

  Base.register_type(Managed)
end

require_dependency 'nic/bmc'
require_dependency 'nic/bond'
require_dependency 'nic/bridge'
