class LogSwitcher < Rails::Rack::Logger
  def initialize(app, opts = {})
    @app = app
    @opts = opts
    @opts[:silenced] ||= []
    @report_regex = %r{^/reports}
    @fact_regex   = %r{^/fact}   # This will match /fact_values and /facts but /host/:id/facts will end up in the main log.
  end

  def call(env)
    if env['PATH_INFO'] =~ @report_regex
      ActiveRecord::Base.logger = ActionController::Base.logger = @logger = Foreman::report_logger
    elsif env['PATH_INFO'] =~ @fact_regex
      ActiveRecord::Base.logger = ActionController::Base.logger = @logger = Foreman::fact_logger
    else
      ActiveRecord::Base.logger = ActionController::Base.logger = @logger = Foreman::default_logger
    end

    super(env)
  end
end