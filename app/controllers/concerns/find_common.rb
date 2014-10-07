# this mixin is used by both ApplicationController and Api::BaseController
# searches for an object based on its id, name, label, etc and assign it to an instance variable
# friendly_id performs the logic if params[:id] is 'id' or 'id-name' or 'name'

module FindCommon

  # example: @host = Host.find(params[:id])
  def find_resource
    not_found and return if params[:id].blank?
    instance_variable_set("@#{resource_name}", resource_scope.find(params[:id]))
  end

  def resource_name
    controller_name.singularize
  end

  def resource_class
    @resource_class ||= resource_name.classify.constantize
  end

  def resource_scope(options = {})
    @resource_scope ||= begin
      options[:controller] ||= controller_name
      options[:permission] ||= "#{action_permission}_#{options[:controller]}"
      scope = resource_class.scoped
      if resource_class.respond_to?(:authorized)
        scope.authorized(options[:permission], resource_class)
      else
        scope
      end
    end
  end

end
