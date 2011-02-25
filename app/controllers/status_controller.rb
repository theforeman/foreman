class StatusController < ApplicationController

  filter_parameter_logging :password, :password_confirmation
  skip_before_filter :require_login, :only => [:status]
  skip_before_filter :authorize, :only => [:status]

  def status
    respond_to do |format|
      format.html { redirect_to '/' and return }

      format.json do
        result = {}
        # make fake db call, measure duration and report errors
        exception_watch(result) { User.first }
        render :json => result
      end
    end
  end

  # check for exception - set the result code and duration time
  def exception_watch(result, &block)
    begin
      start = Time.new
      yield
      result[:result] = 'ok'
      result[:db_duration_ms] = ((Time.new - start) * 1000).round.to_s
    rescue Exception => e
      result[:result] = 'fail'
      result[:message] = e.message
    end
  end

end
