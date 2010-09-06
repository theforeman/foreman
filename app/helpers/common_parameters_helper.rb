module CommonParametersHelper
  # Return true if user is authorized for controller/action OR controller/action@type, otherwise false
  def authorized_via_my_scope(controller, action)
    return true if authorized_for(controller, action)

    operation = "#{action}_my_#{controller.singularize}".to_sym
    User.current.allowed_to?(operation) and User.current.send(controller).include?(eval("@#{controller.singularize}"))
  end
end
