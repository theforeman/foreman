class PowerManager
  SUPPORTED_ACTIONS = [N_('start'), N_('stop'), N_('poweroff'), N_('reboot'), N_('reset'), N_('state')]

  def initialize(opts = {})
    @host = opts[:host]
  end

  def self.method_missing(method, *args)
    logger.warn "invalid power state request #{action} for host: #{host}"
    raise ::Foreman::Exception.new(N_("Invalid power state request: %{action}, supported actions are %{supported}"), { :action => action, :supported => SUPPORTED_ACTIONS })
  end

  def state
    N_("Unknown")
  end

  def logger
    Rails.logger
  end

  private
  attr_reader :host

end
