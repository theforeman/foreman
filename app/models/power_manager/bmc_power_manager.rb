class BMCPowerManager < PowerManager

  def initialize(opts = {})
    super(opts)
    @proxy = host.bmc_proxy
  end

  SUPPORTED_ACTIONS.each do |method|
    define_method method do                             # def start
      proxy.power(:action => action_map[method.to_sym]) #   proxy.power(:action => 'on')
    end                                                 # end
  end

  private
  attr_reader :proxy

  #TODO: consider moving this to the proxy code, so we can just delegate like as with Virt.
  def action_map
    {
      :start    => 'on',
      :stop     => 'off',
      :poweroff => 'off',
      :reboot   => 'soft',
      :reset    => 'cycle',
      :state    => 'status'
    }
  end

end
