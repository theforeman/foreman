# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  filter_parameter_logging :root_pass

  # standard layout to all controllers
  layout 'standard'

  def self.active_scaffold_controller_for(klass)
    return FactNamesController if klass == Puppet::Rails::FactName
    return FactValuesController if klass == Puppet::Rails::FactValue
    return HostsController if klass == Puppet::Rails::Host
    return "#{klass}ScaffoldController".constantize rescue super
  end
end
