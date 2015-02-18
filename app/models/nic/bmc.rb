module Nic
  class BMC < Managed
    PROVIDERS = %w(IPMI)
    validates :provider, :presence => true, :inclusion => { :in => PROVIDERS }

    register_to_enc_transformation :type, lambda { |type| type.constantize.humanized_name }

    def proxy
      if subnet.present?
        proxy = subnet.proxies.select { |subnet_proxy| subnet_proxy.features.map(&:name).include?("BMC") }.first
      end
      proxy ||= SmartProxy.with_features("BMC").first
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

    def enc_attributes
      @enc_attributes ||= (super + %w(username password provider))
    end
  end

  Base.register_type(BMC)
end
