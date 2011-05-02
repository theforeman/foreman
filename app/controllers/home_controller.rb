class HomeController < ApplicationController
  skip_before_filter :require_login, :only => [:status]
  skip_before_filter :authorize, :only => [:status]

  def settings
  end

  def status
    respond_to do |format|
      format.html { redirect_to root_path and return }

      format.json do
        # make fake db call, measure duration and report errors
        result = exception_watch { User.first }
        render :json => result, :status => result[:status]
      end
    end
  end

  private
  # check for exception - set the result code and duration time
  def exception_watch &block
    start = Time.now
    result = {}
    yield
    result[:result] = 'ok'
    result[:status] = 200
    result[:version] = SETTINGS[:version]
    result[:db_duration_ms] = ((Time.now - start) * 1000).round.to_s
  rescue Exception => e
    result[:result] = 'fail'
    result[:status] = 500
    result[:message] = e.message
  ensure
    return result
  end
end
