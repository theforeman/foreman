module CommonParametersHelper
  # Return true if user is authorized for controller/action OR controller/action@type, otherwise false
  # third argument may be specific object (usually for edit and destroy actions)
  def authorized_via_my_scope(controller, action, object = nil)
    authorized_for(:controller => controller, :action => action, :auth_object => object)
  end

  def parameters_title
    _("Parameters that would be associated with hosts in this %s") % (type)
  end

  def parameter_value_field value
    content_tag :div, :class => "form-group condensed"  do
      text_area_tag("value_#{value[:value]}", value[:value], :rows => (value[:value].to_s.lines.count || 1 rescue 1),
                    :class => "col-md-5", :disabled => true) +
      content_tag(:span, :class => "help-block") { popover(_("Additional info"), _("<b>Source:</b> %s") % _(value[:source].to_s))}
    end
  end

end
