require_dependency "app/services/ping"

Rails.logger.warn("Rails cache does not work or is misconfigured") if Ping.rails_cache_check != 'ok'
