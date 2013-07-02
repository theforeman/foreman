module Nic
  class BMC < Managed

    ATTRIBUTES = [:username, :password, :provider]
    attr_accessible :updated_at, *ATTRIBUTES

    PROVIDERS = %w(IPMI)
    validates_inclusion_of :provider, :in => PROVIDERS

    ATTRIBUTES.each do |method|
      define_method method do
        self.attrs ||= { }
        self.attrs[method]
      end

      define_method "#{method}=" do |value|
        self.attrs         ||= { }
        old_value = attrs[method]
        self.attrs[method] = value
        # attrs_will_change! makes the record dirty. Otherwise, rails has a bug that it won't save if no other field is changed.
        self.attrs_will_change! if (old_value != value)
      end
    end


    def proxy
      # try to find a bmc proxy in the same subnet as our bmc device
      proxy   = SmartProxy.bmc_proxies.joins(:subnets).where(['dhcp_id = ? or tftp_id = ?', subnet_id, subnet_id]).first if subnet_id
      proxy ||= SmartProxy.bmc_proxies.first
      raise Foreman::Exception.new(N_('Unable to find a proxy with BMC feature')) if proxy.nil?
      ProxyAPI::BMC.new({ :host_ip  => ip,
                          :url      => proxy.url,
                          :user     => username,
                          :password => password })
    end

  end
end