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
    popover_tag = popover('', _("<b>Source:</b> %{type} %{name}") % { :type => _(value[:source]), :name => html_escape(source_name) }, :data => { :placement => 'top' })
    content_tag(:div, parameter_value_content("value_#{value[:safe_value]}", value[:safe_value], :popover => popover_tag, :disabled => true) + fullscreen_input, :class => 'input-group')
  end

  def parameter_value_content(id, value, options)
    lookup_key = options[:lookup_key]

    option_hash = { :rows => 1,
                    :class => 'form-control no-stretch',
                    :'data-property' => 'value',
                    :'data-hidden-value' => LookupKey.hidden_value,
                    :'data-inherited-value' => options[:inherited_value],
                    :name => options[:name].to_s,
                    :disabled => options[:disabled] }

    if lookup_key.present? && lookup_key.hidden_value?
      field = password_field_tag(id, value, option_hash)
    else
      field = text_area_tag(id, value, option_hash)
    end

    content_tag(:span, options[:popover], :class => "input-group-addon") + field
  end

  def use_puppet_default_help link_title = nil, title = _("Use Puppet default")
    popover(link_title, _("Do not send this parameter via the ENC.<br>Puppet will use the value defined in the manifest."), :title => title)
  end

  def hidden_value_field(f, field, value, disabled, options = {})
    hidden = options.delete(:hidden_value)
    if hidden || f.object.hidden_value?
      input = f.password_field(field, :disabled => disabled, :value => value, :class => 'form-control')
    else
      input = f.text_area(field, options.merge(:disabled => disabled,
                                               :class => "form-control no-stretch",
                                               :rows => 1,
                                               :placeholder => _("Value")))
    end
    input_group(input, input_group_btn(hidden_toggle(f.object.hidden_value?), fullscreen_button("$(this).closest('.input-group').find('input,textarea')")))
  end
end
