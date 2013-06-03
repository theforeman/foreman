module CommonParametersHelper
  # Return true if user is authorized for controller/action OR controller/action@type, otherwise false
  def authorized_via_my_scope(controller, action)
    return true if authorized_for(controller, action)

    operation = "#{action}_my_#{controller.singularize}".to_sym
    User.current.allowed_to?(operation) and User.current.send(controller).include?(instance_variable_get("@#{controller.singularize}"))
  end

  def parameters_title
    _("Parameters that would be associated with hosts in this %s") % (type)
  end

  def parameter_value_field value
    content_tag :div, :class => "control-group condensed"  do
      text_area_tag("value_#{value[:value]}", value[:value], :rows => (value[:value].to_s.lines.count || 1 rescue 1),
                    :class => "span5", :disabled => true) +
      content_tag(:span, :class => "help-inline") { popover(_("Additional info"), _("<b>Source:</b> %s") % (value[:source]))}
    end
  end

end
