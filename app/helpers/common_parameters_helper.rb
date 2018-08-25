module CommonParametersHelper
  # Return true if user is authorized for controller/action OR controller/action@type, otherwise false
  # third argument may be specific object (usually for edit and destroy actions)
  def authorized_via_my_scope(controller, action, object = nil)
    authorized_for(:controller => controller, :action => action, :auth_object => object)
  end

  def parameters_title
    _("Parameters that would be associated with hosts in this %s") % type
  end

  def parameter_value_field(value)
    source_name = value[:source_name] ? "(#{value[:source_name]})" : nil
    popover_tag = popover('', _("<b>Source:</b> %{type} %{name}") % { :type => _(value[:source]), :name => html_escape(source_name) }, :data => { :placement => 'top' })
    content_tag(:div, parameter_value_content("value_#{value[:safe_value]}", value[:safe_value], :popover => popover_tag, :disabled => true) + fullscreen_input, :class => 'input-group')
  end

  def parameter_value_content(id, value, options)
    content_tag(:span, options[:popover], :class => "input-group-addon") + lookup_key_field(id, value, options)
  end

  def omit_help
    popover(nil, omit_help_body, :title => omit_help_title)
  end

  def omit_help_title
    _("Omit parameter from classification")
  end

  def omit_help_body
    _("Foreman will not send this parameter in classification output.")
  end

  def hidden_value_field(f, field, disabled, options = {})
    hidden = options.delete(:hidden_value) || f.object.hidden_value?
    html_class = "form-control no-stretch"
    html_class += " masked-input" if hidden

    input = f.text_area(field, options.merge(:disabled => disabled,
                                             :class => html_class,
                                             :rows => 1,
                                             :id => dom_id(f.object) + '_value',
                                             :placeholder => _("Value")))

    input_group(input, input_group_btn(hidden_toggle(f.object.hidden_value?), fullscreen_button("$(this).closest('.input-group').find('input,textarea')")))
  end

  def lookup_key_field(id, value, options)
    lookup_key = options[:lookup_key]

    option_hash = { :rows => 1,
                    :class => 'form-control no-stretch',
                    :'data-property' => 'value',
                    :'data-hidden-value' => LookupKey.hidden_value,
                    :'data-inherited-value' => options[:inherited_value],
                    :name => options[:name].to_s,
                    :disabled => options[:disabled] }

    option_hash[:class] += " masked-input" if lookup_key.present? && options[:lookup_key_hidden_value?]

    case options[:lookup_key_type]
    when "boolean"
      select_tag(id, options_for_select(['true', 'false'], value), option_hash)
    when "integer", "real"
      number_field_tag(id, value, option_hash)
    else
      text_area_tag(id, value, option_hash)
    end
  end

  def authorized_resource_parameters(resource, type)
    parameters_by_type = resource.send(type)
    @allowed_ids_hash = find_allowed_param_ids_per_action(parameters_by_type)
    resource_parameters = parameters_by_type.select { |p| @allowed_ids_hash[:ids_to_view].include?(p.id) }
    resource_parameters += parameters_by_type.select(&:new_record?)
    resource_parameters
  end

  def can_edit_parameter?(parameter)
    @allowed_ids_hash[:ids_to_edit].include?(parameter.id)
  end

  def can_destroy_parameter?(parameter)
    @allowed_ids_hash[:ids_to_destroy].include?(parameter.id)
  end

  def can_create_parameter?(parameter)
    @can_create_param ||= authorizer.can?(:create_params)
  end

  private

  def find_allowed_param_ids_per_action(parameters_by_type)
    {
      ids_to_view: parameters_by_type.authorized(:view_params).pluck(:id),
      ids_to_edit: parameters_by_type.authorized(:edit_params).pluck(:id),
      ids_to_destroy: parameters_by_type.authorized(:destroy_params).pluck(:id)
    }
  end
end
