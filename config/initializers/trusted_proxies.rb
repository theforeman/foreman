# Workaround Rails issue https://github.com/rails/rails/issues/5223
Foreman::Application.config.action_dispatch.trusted_proxies = %w(::1 127.0.0.1). map { |proxy| IPAddr.new(proxy) }
