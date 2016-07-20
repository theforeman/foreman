module Api::V2::HostsControllerExtension
  extend ActiveSupport::Concern

  included do
    before_action :find_resource
  end

  module ClassMethods
    def check_permissions_for(methods)
      before_action :permissions_check, :only => methods
    end
  end

  def permissions_check
    permission = "#{params[:action]}_hosts".to_sym
    deny_access unless Host.authorized(permission, Host).find(@host.id)
  end

  def resource_class
    Host::Managed
  end

  def resource_name(resource = 'host')
    super(resource)
  end
end
