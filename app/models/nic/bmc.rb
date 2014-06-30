module Nic
  class BMC < Managed

    PROVIDERS = %w(IPMI)
    validates :provider, :presence => true, :inclusion => { :in => PROVIDERS }

    def proxy
      if subnet.present?
        proxy = subnet.proxies.select { |proxy| proxy.features.map(&:name).include?("BMC") }.first
      end
      proxy ||= SmartProxy.with_features("BMC").first
      raise Foreman::Exception.new(N_('Unable to find a proxy with BMC feature')) if proxy.nil?
      ProxyAPI::BMC.new({ :host_ip  => ip,
                          :url      => proxy.url,
                          :user     => username,
                          :password => password })
    end

  end
end
