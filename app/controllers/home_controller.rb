class HomeController < ApplicationController
  skip_before_filter :require_login, :only => [:status]
  skip_before_filter :authorize, :set_taxonomy, :only => [:status]
  skip_before_filter :session_expiry, :update_activity_time, :only => :status

  def settings
  end

  def status
    respond_to do |format|
      format.json do
        # make fake db call, measure duration and report errors
        result = exception_watch { User.first }
        render :json => result, :status => result[:status]
      end
      format.all { invalid_request }
    end
  end

  private

  # check for exception - set the result code and duration time
  def exception_watch(&block)
    start = Time.now
    result = {}
    begin
      yield
      result[:result] = 'ok'
      result[:status] = :ok
      result[:version] = SETTINGS[:version].full
      result[:db_duration_ms] = ((Time.now - start) * 1000).round.to_s
    rescue => e
      result[:result] = 'fail'
      result[:status] = :internal_server_error
      result[:message] = e.message
    end
    result
  end
end
