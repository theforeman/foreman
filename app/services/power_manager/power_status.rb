module PowerManager
  class PowerStatus < Base
    HOST_POWER = {
      on:  { state: 'on', title: N_('On') },
      off: { state: 'off', title: N_('Off') },
      na:  { state: 'na', title: N_('N/A') },
    }.freeze

    DEFAULT_TIMEOUT = 3

    def power_state(timeout = DEFAULT_TIMEOUT)
      result = { id: host.id }.merge(HOST_POWER[:na])

      if host.supports_power?
        result = host_power_ping(result, timeout)
      else
        result[:statusText] = _('Power operations are not enabled on this host.')
      end

      result
    end

    private

    def host_power_ping(result, timeout = DEFAULT_TIMEOUT)
      req_timeout = timeout.nil? || timeout.to_i == 0 ? DEFAULT_TIMEOUT : timeout.to_i
      Timeout.timeout(req_timeout) do
        result.merge!(HOST_POWER[host.supports_power_and_running? ? :on : :off])
      end

      result
    rescue Timeout::Error
      logger.debug("Failed to retrieve power status for #{host} within #{req_timeout} seconds.")

      result[:statusText] = n_("Failed to retrieve power status for %{host} within %{req_timeout} second.",
        "Failed to retrieve power status for %{host} within %{req_timeout} seconds.", req_timeout) %
                              {host: host, req_timeout: req_timeout}
      result
    end
  end
end
