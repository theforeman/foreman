# Foreman telemetry global setup.
telemetry = Foreman::Telemetry.instance
if SETTINGS[:telemetry] && (Rails.env.production? || Rails.env.development?)
  telemetry.setup(SETTINGS[:telemetry])
end

# Register Rails notifications metrics
telemetry.register_rails

# Register Ruby VM metrics
telemetry.register_ruby
