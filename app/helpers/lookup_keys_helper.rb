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
        :label_help => _(
          "<b>List</b> A list of the allowed values separated by comma, specified in the Validator rule field. The default value and all input values must then be one of the specified allowed value.<br/>" +
          "<b>Regexp</b> Validates the default value and all input values with the regular expression in the Validator rule field. E.g. <code>[0-9]+\.[0-9]+</code><br/>"
        ).html_safe,
        :label_help_options => { :title => _("Validation types") } }
  end

  def can_edit_params?
    authorized_via_my_scope("host_editing", "edit_params")
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
end
