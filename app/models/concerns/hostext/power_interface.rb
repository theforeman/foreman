module Hostext
  module PowerInterface
    extend ActiveSupport::Concern

    def power
      opts = {:host => self}
      if compute_resource_id && uuid
        PowerManager::Virt.new(opts)
      elsif bmc_available?
        PowerManager::BMC.new(opts)
      else
        raise ::Foreman::Exception.new(N_("Unknown power management support - can't continue"))
      end
    end

    def supports_power?
      (uuid && compute_resource_id) || bmc_available?
    end

    def supports_power_and_running?
      return false unless supports_power?
      power.ready?
      # return false if the proxyapi/bmc raised an error (and therefore do not know if power is supported)
    rescue ProxyAPI::ProxyException
      false
    end
  end
end
