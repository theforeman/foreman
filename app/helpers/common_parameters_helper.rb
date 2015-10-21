module CommonParametersHelper
  # Return true if user is authorized for controller/action OR controller/action@type, otherwise false
  # third argument may be specific object (usually for edit and destroy actions)
  def authorized_via_my_scope(controller, action, object = nil)
    authorized_for(:controller => controller, :action => action, :auth_object => object)
  end

  def parameters_title
    _("Parameters that would be associated with hosts in this %s") % (type)
  end

  def parameter_value_field(value)
    source_name = value[:source_name] ? "(#{value[:source_name]})" : nil
    popover_tag = popover('', _("<b>Source:</b> %{type} %{name}") % { :type => _(value[:source].to_s), :name => source_name }, :data => { :placement => 'top' })
    content_tag(:div, parameter_value_content("value_#{value[:safe_value]}", value[:safe_value], :popover => popover_tag, :disabled => true) + fullscreen_input, :class => 'input-group')
  end

  def parameter_value_content(id, value, options)
    content_tag(:span, options[:popover], :class => "input-group-addon") +
      text_area_tag(id, value, { :rows => 1,
                                 :class => 'form-control no-stretch',
                                 :'data-property' => 'value',
                                 :'data-hidden-value' => Parameter.hidden_value,
                                 :'data-original-value' => options[:original_value],
                                 :name => options[:name].to_s,
                                 :disabled => options[:disabled] })
  end

  def use_puppet_default_help link_title = nil, title = _("Use Puppet default")
    popover(link_title, _("Do not send this parameter via the ENC.<br>Puppet will use the value defined in the manifest."), :title => title)
  end
end
