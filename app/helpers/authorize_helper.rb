module AuthorizeHelper
  # Return true if user is authorized for controller/action, otherwise false
  # +options+ : Hash containing
  #             :controller : String or symbol for the controller, defaults to params[:controller]
  #             :action     : String or symbol for the action
  #             :id         : Id parameter
  #             :auth_action: String or symbol for the action, this has higher priority that :action
  #             :auth_object: Specific object on which we may verify particular permission
  #             :authorizer : Specific authorizer to perform authorization on (handy to inject authorizer with base collection)
  #             :permission : Specific permission to check authorization on (handy on custom permission names)
  def authorized_for(options)
    action          = options.delete(:auth_action) || options[:action]
    object          = options.delete(:auth_object)
    user            = User.current
    controller      = options[:controller] || params[:controller]
    controller_name = controller.to_s.gsub(/::/, "_").underscore
    id              = options[:id]
    user_id         = options[:user_id].to_param
    permission      = options.delete(:permission) || [action, controller_name].join('_')

    if object.nil?
      user.allowed_to?({ :controller => controller_name, :action => action, :id => id, :user_id => user_id }) rescue false
    else
      authorizer = options.delete(:authorizer) || Authorizer.new(user)
      authorizer.can?(permission, object) rescue false
    end
  end

  def authorizer
    @authorizer ||= Authorizer.new(User.current, :collection => instance_variable_get("@#{controller_name}"))
  end

  def can_create?
    authorized_for(controller: controller_permission, action: 'create', user_id: User.current.id, authorizer: authorizer)
  end

  def can_edit?
    authorized_for(controller: controller_permission, action: 'edit', user_id: User.current.id, authorizer: authorizer)
  end
end
