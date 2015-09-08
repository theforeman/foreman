module Nic
  class BMC < Managed
    PROVIDERS = %w(IPMI)
    before_validation :ensure_physical
    before_validation { |nic| nic.provider.try(:upcase!) }
    validates :provider, :presence => true, :inclusion => { :in => PROVIDERS }
    validates :mac, :presence => true, :if => :managed?
    validate :validate_bmc_proxy

    def virtual
      false
    end
    alias_method :virtual?, :virtual

    register_to_enc_transformation :type, ->(type) { type.constantize.humanized_name }

    def proxy
      proxy = bmc_proxy
      raise Foreman::Exception.new(N_('Unable to find a proxy with BMC feature')) if proxy.nil?
      ProxyAPI::BMC.new({ :host_ip  => ip,
                          :url      => proxy.url,
                          :user     => username,
                          :password => password })
    end

    def self.humanized_name
      N_('BMC')
    end

    private

    def ensure_physical
      self.virtual = false
      true # don't stop validation chain
    end

    def enc_attributes
      @enc_attributes ||= (super + %w(username password provider))
    end

    private

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
