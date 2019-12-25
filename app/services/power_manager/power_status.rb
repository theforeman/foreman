module PowerManager
  class PowerStatus < Base
    HOST_POWER = {
      on:  { state: 'on', title: N_('On') },
      off: { state: 'off', title: N_('Off') },
      na:  { state: 'na', title: N_('N/A') },
    }.freeze

    def power_state
      result = { id: host.id }.merge(HOST_POWER[:na])

      if host.supports_power?
        result = host_power_ping(result)
      else
        result[:statusText] = _('Power operations are not enabled on this host.')
      end

      result
    end

    private

    def host_power_ping(result)
      timeout = 3

      Timeout.timeout(timeout) do
        result.merge!(HOST_POWER[host.supports_power_and_running? ? :on : :off])
      end

      result
    rescue Timeout::Error
      logger.debug("Failed to retrieve power status for #{host} within #{timeout} seconds.")

      result[:statusText] = n_("Failed to retrieve power status for %{host} within %{timeout} second.",
        "Failed to retrieve power status for %{host} within %{timeout} seconds.", timeout) %
                              {host: host, timeout: timeout}
      result
    end
  end
end
