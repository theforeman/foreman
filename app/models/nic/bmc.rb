module Nic
  class BMC < Managed
    PROVIDERS = %w(IPMI SSH)
    before_validation :ensure_physical
    before_validation { |nic| nic.provider.try(:upcase!) }
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
      ProxyAPI::BMC.new({ :host_ip  => ip,
                          :url      => proxy.url,
                          :user     => username,
                          :password => password_unredacted })
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

    private

    def ensure_physical
      self.virtual = false
      true # don't stop validation chain
    end

    def bmc_proxy
      if subnet.present?
        proxy = subnet.proxies.find { |subnet_proxy| subnet_proxy.has_feature?('BMC') }
      end
      proxy ||= SmartProxy.unscoped.with_features("BMC").first
      proxy
    end

    def validate_bmc_proxy
      return true unless managed?
      return true if host && !host_managed?
      unless bmc_proxy
        errors.add(:type, N_('There is no proxy with BMC feature set up. Please register a smart proxy with this feature.'))
      end
    end
  end

  Base.register_type(BMC)
end
