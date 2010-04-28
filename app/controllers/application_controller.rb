# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  filter_parameter_logging :root_pass

  # standard layout to all controllers
  layout 'standard'
  helper 'layout'

  before_filter :require_ssl, :require_login

  def self.active_scaffold_controller_for(klass)
    return FactNamesController if klass == Puppet::Rails::FactName
    return FactValuesController if klass == Puppet::Rails::FactValue
    return "#{klass}ScaffoldController".constantize rescue super
  end

  protected

  def require_ssl
    # if SSL is not configured, don't bother forcing it.
    return true unless SETTINGS[:require_ssl]
    # don't force SSL on localhost
    return true if request.host=~/localhost|127.0.0.1/
    # finally - redirect
    redirect_to :protocol => 'https' and return if request.protocol != 'https' and not request.ssl?
  end


  #Force a user to login if ldap authentication is enabled
  def require_login
    return true unless SETTINGS[:ldap]
    unless (session[:user] and (@user = User.find(session[:user])))
      session[:original_uri] = request.request_uri
      redirect_to login_path
    end
  end

  # returns current user
  def current_user
    @user
  end

  def invalid_request
      render :text => 'Invalid query', :status => 400 and return
  end

  def setgraph chart, data, options = {}
    data[:labels].each {|l| chart.add_column *l }
    chart.add_rows data[:values]
    defaults = { :width => 400, :height => 240, :is3D => true,
      :backgroundColor => "#E6DFCF", :legendBackgroundColor => "#E6DFCF" }

    defaults.merge(options).each {|k,v| chart.send "#{k}=",v if chart.respond_to? k}
    return chart
  end

end
