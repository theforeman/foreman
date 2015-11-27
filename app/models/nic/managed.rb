module Nic
  class Managed < Interface
    include Orchestration
    include Orchestration::DHCP
    include Orchestration::DNS
    include Orchestration::TFTP

    include EncOutput
    include Foreman::Renderer

    before_validation :set_provisioning_flag
    after_save :update_lookup_value_fqdn_matchers, :drop_host_cache

    # Interface normally are not executed by them self, so we use the host queue and related methods.
    # this ensures our orchestration works on both a host and a managed interface
    delegate :progress_report_id, :capabilities, :compute_resource,
             :operatingsystem, :provisioning_template, :jumpstart?, :build, :build?, :os, :arch,
             :image_build?, :pxe_build?, :pxe_build?, :token, :to_ip_address, :model, :to => :host
    delegate :operatingsystem_id, :hostgroup_id, :environment_id,
             :overwrite?, :to => :host, :allow_nil => true

    register_to_enc_transformation :type, ->(type) { type.constantize.humanized_name }

    # this ensures we can create an interface even when there is no host queue
    # e.g. outside to Host nested attributes
    def queue_with_host
      if host && host.respond_to?(:queue)
        logger.debug 'Using host queue'
        host.queue
      else
        logger.debug 'Using nic queue'
        queue_without_host
      end
    end
    alias_method_chain :queue, :host

    def hostname
      if domain.present? && name.present?
        "#{shortname}.#{domain.name}"
      else
        name
      end
    end

    def self.humanized_name
      N_('Interface')
    end

    private

    def enc_attributes
      @enc_attributes ||= begin
        base = super + %w(ip mac type name attrs virtual link identifier managed primary provision)
        base += %w(tag attached_to) if virtual?
        base
      end
    end

    def embed_associations
      @embed_attributes ||= begin
        super + %w(subnet)
      end
    end

    # Copied from compute orchestraion
    def ip_available?
      ip.present? || (host.present? && host.compute_provides?(:ip)) # TODO revist this for VMs
    end

    def mac_available?
      mac.present? || (host.present? && host.compute_provides?(:mac)) # TODO revist this for VMs
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
      return unless fqdn_changed?
      LookupValue.where(:match => "fqdn=#{fqdn_was}").update_all(:match => host.send(:lookup_value_match))
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
require_dependency 'nic/bootable'
