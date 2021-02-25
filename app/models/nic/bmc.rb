module Nic
  class BMC < Managed
    PROVIDERS = %w(IPMI Redfish SSH)
    before_validation :ensure_physical
    before_validation { |nic| nic.provider == 'Redfish' || nic.provider.try(:upcase!) }
    validates :provider, :presence => true, :inclusion => { :in => PROVIDERS }
    validates :mac, :presence => true, :if => :managed?
    validate :validate_bmc_proxy

    def virtual
      false
    end
    alias_method :virtual?, :virtual

    attr_exportable :provider, :username, :password

    def proxy
      proxy = bmc_proxy
      raise Foreman::Exception.new(N_('Unable to find a proxy with BMC feature')) if proxy.nil?
      args = {
        :host_ip => ip,
        :url => proxy.url,
        :user => username,
        :password => password_unredacted,
      }
      args[:bmc_provider] = provider if provider != 'IPMI'
      ProxyAPI::BMC.new(args)
    end

    def self.humanized_name
      N_('BMC')
    end

    class Jail < Nic::Managed::Jail
      allow :provider, :username, :password
    end

    alias_method :password_unredacted, :password
    def password
      Setting[:bmc_credentials_accessible] ? password_unredacted : nil
    end

    def credentials_present?
      password_unredacted.present? && username.present?
    end

    private

    def ensure_physical
      self.virtual = false
      true # don't stop validation chain
    end

    def bmc_proxy
      subnet&.bmc || \
        raise(::Foreman::BMCFeatureException.new(N_('There is no proxy with BMC feature set up. Associate a BMC feature with a subnet.')))
    end

    def validate_bmc_proxy
      return true unless managed?
      return true if host && !host_managed?
      bmc_proxy
    rescue ::Foreman::BMCFeatureException => e
      errors.add(:type, e.message)
    end
  end

  Base.register_type(BMC)
end
