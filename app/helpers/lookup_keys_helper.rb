module LookupKeysHelper
  def remove_child_link(name, f, opts = {})
    opts[:class] = [opts[:class], "remove_nested_fields"].compact.join(" ")
    f.hidden_field(opts[:method] || :_destroy) + link_to_function(name, "remove_child_node(this);", opts)
  end

  def delete_child_link(name, f, opts = {})
    opts[:class] = [opts[:class], "remove_nested_fields"].compact.join(" ")
    link_to_function(name, "delete_child_node(this);", opts)
  end

  def add_child_link(name, association, opts = {})
    opts[:class] = [opts[:class], "add_nested_fields btn btn-primary"].compact.join(" ")
    opts[:"data-association"] = association
    link_to_function(name.to_s, "add_child_node(this);", opts)
  end

  def show_puppet_class(f)
    # In case of a new smart-var inside a puppetclass (REST nesting only), or a class parameter:
    # Show the parent puppetclass as a context, but permit no change.
    unless @puppetclass
      if params["puppetclass_id"]
        select_f f, :puppetclass_id, [Puppetclass.find(params["puppetclass_id"])], :id, :to_label, {}, {:label => _("Puppet class"), :disabled => true}
      elsif f.object.puppet? && f.object.param_class
        text_f(f, :puppetclass_id, :label => _('Puppet Class'), :value => f.object.param_class, :disabled => true)
      else # new smart-var with no particular context
        # Give a select for choosing the parent puppetclass
        puppetclasses = accessible_resource(f.object, :puppetclass)
        select_f(f, :puppetclass_id, puppetclasses, :id, :to_label, { :include_blank => true }, {:label => _("Puppet class")})
      end
      # nested smart-vars form in a tab of puppetclass/_form: no edition allowed, and the puppetclass is already visible as a context
    end
  end

  def validator_type_selector(f)
    selectable_f f, :validator_type, options_for_select(LookupKey::VALIDATOR_TYPES.map { |e| [_(e), e] }, f.object.validator_type), {:include_blank => _("None")},
      { :disabled => (f.object.puppet? && !f.object.override), :size => "col-md-8", :class => "without_select2",
        :onchange => 'validatorTypeSelected(this)',
        :label_help => _("<dl>" +
          "<dt>List</dt> <dd>A list of the allowed values, specified in the Validator rule field.</dd>" +
          "<dt>Regexp</dt> <dd>Validates the input with the regular expression in the Validator rule field.</dd>" +
          "</dl>").html_safe,
        :label_help_options => { :title => _("Validation types") } }
  end

  def overridable_lookup_keys(klass, obj)
    klass.class_params.override.where(:environment_classes => {:environment_id => obj.environment})
  end

  def can_edit_params?
    authorized_via_my_scope("host_editing", "edit_params")
  end

  def lookup_key_with_diagnostic(obj, lookup_key, lookup_value)
    value, matcher = value_matcher(obj, lookup_key)
    inherited_value = LookupKey.format_value_before_type_cast(value, lookup_key.key_type)
    effective_value = lookup_value.lookup_key_id.nil? ? inherited_value.to_s : lookup_value.value_before_type_cast.to_s
    warnings = lookup_key_warnings(lookup_key.required, effective_value.present?)
    popover_value = lookup_key.hidden_value? ? lookup_key.hidden_value : inherited_value

    parameter_value_content(
      "#{parameters_receiver}_lookup_values_attributes_#{lookup_key.id}_value",
      effective_value,
      :popover => diagnostic_popover(lookup_key, matcher, popover_value, warnings),
      :name => "#{lookup_value_name_prefix(lookup_key.id)}[value]",
      :disabled => !lookup_key.overridden?(obj) || lookup_value.omit || !can_edit_params?,
      :inherited_value => inherited_value,
      :lookup_key => lookup_key,
      :hidden_value? => lookup_key.hidden_value?,
      :lookup_key_type => lookup_key.key_type)
  end

  def value_matcher(obj, lookup_key)
    if parameters_receiver == "host"
      value = value_hash_cache(obj)[lookup_key.id]
      value_for_key = value.try(:[], lookup_key.key)
      if value_for_key.present?
        [value_for_key[:value], "#{value_for_key[:element]} (#{value_for_key[:element_name]})"]
      else
        [lookup_key.default_value, _("Default value")]
      end
    else # hostgroup
      obj.inherited_lookup_value(lookup_key)
    end
  end

  def diagnostic_popover(lookup_key, matcher, inherited_value, warnings)
    description = lookup_key_description(lookup_key, matcher, inherited_value)
    popover('', description.prepend(warnings[:text]),
      :data => { :placement => 'top' },
      :title => _("Original value info"),
      :icon => "info-circle",
      :kind => "fa")
  end

  def lookup_key_description(lookup_key, matcher, inherited_value)
    _("<b>Description:</b> %{desc}<br/>
     <b>Type:</b> %{type}<br/>
     <b>Matcher:</b> %{matcher}<br/>
     <b>Inherited value:</b> %{inherited_value}") %
    { :desc => html_escape(lookup_key.description), :type => lookup_key.key_type,
      :matcher => html_escape(matcher), :inherited_value => html_escape(inherited_value) }
  end

  def lookup_key_warnings(required, has_value)
    return { :text => '', :icon => 'info' } if has_value

    if required
      { :text => _("Required parameter without value.<br/><b>Please override!</b><br/>"),
        :icon => "error-circle-o" }
    else
      { :text => _("Optional parameter without value.<br/><i>Still managed by Foreman, the value will be empty.</i><br/>"),
        :icon => "warning-triangle-o" }
    end
  end

  def override_toggle(overridden)
    return unless can_edit_params?
    link_to_function(icon_text('pencil-square-o', '', :kind => 'fa'), "override_class_param(this)",
      :title => _("Override this value"),
      :'data-tag' => 'override',
      :class => "btn btn-default btn-md btn-override #{'hide' if overridden}") +
      link_to_function(icon_text('times', '', :kind => 'fa'), "override_class_param(this)",
        :title => _("Remove this override"),
       :'data-tag' => 'remove',
       :class => "btn btn-default btn-md btn-override #{'hide' unless overridden}")
  end

  def hidden_toggle(hidden, hide_icon = 'eye-slash', unhide_icon = 'eye', strikethrough = false)
    return unless can_edit_params?
    if strikethrough && !hidden
      link_to_function(icon_text(hide_icon, '', :kind => 'fa'), "", :class => "btn btn-default btn-md btn-hide", :disabled => "disabled", :rel => "twipsy", :title => _("This value is not hidden"))
    else
      link_to_function(icon_text(unhide_icon, '', :kind => 'fa'), "input_group_hidden(this)",
        :title => _("Unhide this value"),
        :class => "btn btn-default btn-md btn-hide #{'hide' unless hidden}") +
          link_to_function(icon_text(hide_icon, "", :class => ('btn-strike' if strikethrough).to_s, :kind => 'fa'), "input_group_hidden(this)",
            :title => _("Hide this value"),
            :class => "btn btn-default btn-md btn-hide #{'hide' if hidden}")
    end
  end

  def lookup_value(host_or_hostgroup, lookup_key)
    lookup_key.overridden_value(host_or_hostgroup) || LookupValue.new
  end

  def omit_check_box(lookup_key, lookup_value, disabled)
    return unless lookup_key.type == "PuppetclassLookupKey"
    check_box(lookup_value_name_prefix(lookup_key.id), :omit,
      :value    => lookup_value.id,
      :disabled => disabled || !can_edit_params?,
      :onchange => "toggleOmitValue(this, 'value')",
      :hidden   => disabled,
      :title    => _('Omit from classification output'),
      :checked  => lookup_value.omit)
  end

  def hidden_lookup_value_fields(lookup_key, lookup_value, disabled)
    return unless can_edit_params?
    value_prefix = lookup_value_name_prefix(lookup_key.id)
    hidden_field(value_prefix, :lookup_key_id, :value => lookup_key.id,
                 :disabled => disabled, :class => 'send_to_remove') +
      hidden_field(value_prefix, :id, :value => lookup_value.id,
                   :disabled => disabled, :class => 'send_to_remove') +
      hidden_field(value_prefix, :_destroy, :value => false,
                   :disabled => disabled, :class => 'send_to_remove destroy')
  end

  # Input tags used to override lookup keys need a 'name' HTML attribute to
  # tell Rails which lookup_value they belong to.
  # This method returns the name attribute for any combination of lookup_key
  # and host/hostgroup. Other objects that may receive parameters too will need
  # to override this method in their respective helpers.
  def lookup_value_name_prefix(lookup_key_id)
    "#{parameters_receiver}[lookup_values_attributes][#{lookup_key_id}]"
  end

  def parameters_receiver
    return 'host' if params.has_key?(:host) || params[:controller] == 'hosts'
    'hostgroup'
  end
end
