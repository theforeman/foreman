class BulkHostsManager
  def initialize(hosts:)
    @hosts = hosts
  end

  def build(reboot: false)
    # returns missed hosts
    @hosts.select do |host|
      success = true
      begin
        host.built(false) if host.build? && host.token_expired?
        host.setBuild
        host.power.reset if reboot && host.supports_power_and_running?
      rescue => error
        Foreman::Logging.exception("Failed to redeploy #{host}.", error)
        success = false
      end
      !success
    end
  end

  def rebuild_configuration
    # returns a hash with a key/value configuration
    all_fails = {}
    @hosts.each do |host|
      result = host.recreate_config
      result.each_pair do |k, v|
        all_fails[k] ||= []
        all_fails[k] << host unless v
      end
    end
    all_fails
  end
end
