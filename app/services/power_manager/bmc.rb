module PowerManager
  class BMC < Base
    def initialize(opts = {})
      super(opts)
      @proxy = host.bmc_proxy
    end

    def ready?
      status == 'on'
    end

    private

    attr_reader :proxy

    # TODO: consider moving this to the proxy code, so we can just delegate like as with Virt.
    def action_map
      super.deep_merge({
                         :start    => 'on',
                         :stop     => 'off',
                         :poweroff => 'off',
                         :reboot   => 'soft',
                         :reset    => 'cycle',
                         :state    => 'status',
                         :ready?   => 'ready?',
                       })
    end

    def default_action(action)
      proxy.power(:action => action.to_s) #   proxy.power(:action => 'on')
    end
  end
end
