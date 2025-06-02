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

    def power_action_v2
      smart_proxy = host.smart_proxies.with_features(:BMC).first

      return false unless smart_proxy
      smart_proxy.has_capability?(:BMC, :power_action_v2)
    end

    # TODO: consider moving this to the proxy code, so we can just delegate like as with Virt.
    def action_map
      super.deep_merge({
        :start    => 'on',
        :stop     => 'off',
        :poweroff => 'off',
        :reboot   => power_action_v2 ? 'do_reboot' : 'soft',
        :reset    => power_action_v2 ? 'do_reset'  : 'cycle',
        :state    => 'status',
        :ready?   => 'ready?',
      })
    end

    # Avoid infinite loop when action_map maps :reboot to 'reboot'.
    # This method was introduced as part of foreman #3073 and smart-proxy #38498
    # to explicitly handle reset/reboot actions, ensuring backward compatibility
    # with older Smart Proxy implementations that do not support the new capabilities.
    def do_reboot
      default_action(:reboot)
    end

    # For the same reason as above, this handles the case where :reset maps to 'reset'.
    def do_reset
      default_action(:reset)
    end

    def default_action(action)
      proxy.power(:action => action.to_s) #   proxy.power(:action => 'on')
    end
  end
end
