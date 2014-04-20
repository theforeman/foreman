module LookupKeysHelper

  def remove_child_link(name, f, opts = {})
    opts[:class] = [opts[:class], "remove_nested_fields"].compact.join(" ")
    f.hidden_field(opts[:method]||:_destroy) + link_to_function(name, "remove_child_node(this);" , opts)
  end

  def add_child_link(name, association, opts = {})
    opts[:class] = [opts[:class], "add_nested_fields btn btn-success"].compact.join(" ")
    opts[:"data-association"] = association
    link_to_function(name.to_s, "add_child_node(this);" , opts)
  end

  def new_child_fields_template(form_builder, association, options = { })
    options[:object]             ||= form_builder.object.class.reflect_on_association(association).klass.new
    options[:partial]            ||= association.to_s.singularize
    options[:form_builder_local] ||= :f
    options[:form_builder_attrs] ||= {}

    content_tag(:div, :class => "#{association}_fields_template", :style => "display: none;") do
        form_builder.fields_for(association, options[:object], :child_index => "new_#{association}") do |f|
        render(:partial => options[:partial], :locals => { options[:form_builder_local] => f }.merge(options[:form_builder_attrs]))
      end
    end
  end

  def show_puppet_class f
    # In case of a new smart-var inside a puppetclass (REST nesting only), or a class parameter:
    # Show the parent puppetclass as a context, but permit no change.
    if params["puppetclass_id"]
      select_f f, :puppetclass_id, [Puppetclass.find(params["puppetclass_id"])], :id, :to_label, {}, {:label => _("Puppet class"), :disabled => true}
    elsif f.object.is_param && f.object.param_class
      field(f, :puppetclass_id, :label => _('Puppet Class')) do
        content_tag(:input, nil, :value => f.object.param_class, :type => 'text', :disabled => true)
      end
    else # new smart-var with no particular context
         # Give a select for choosing the parent puppetclass
      select_f(f, :puppetclass_id, Puppetclass.all, :id, :to_label, { :include_blank => _('None') }, {:label => _("Puppet class")})
    end unless @puppetclass # nested smart-vars form in a tab of puppetclass/_form: no edition allowed, and the puppetclass is already visible as a context
  end

  def param_type_selector f
    selectable_f f, :key_type, options_for_select(LookupKey::KEY_TYPES, f.object.key_type),{},
               { :disabled => (f.object.is_param && !f.object.override), :size => "col-md-8" ,
                 :help_block => popover("Parameter Types",_("<dl>" +
               "<dt>String</dt> <dd>Everything is taken as a string.</dd>" +
               "<dt>Boolean</dt> <dd>Common representation of boolean values are accepted.</dd>" +
               "<dt>Integer</dt> <dd>Integer numbers only, can be negative.</dd>" +
               "<dt>Real</dt> <dd>Accept any numerical input.</dd>" +
               "<dt>Array</dt> <dd>A valid JSON or YAML input, that must evaluate to an array.</dd>" +
               "<dt>Hash</dt> <dd>A valid JSON or YAML input, that must evaluate to an object/map/dict/hash.</dd>" +
               "<dt>YAML</dt> <dd>Any valid YAML input.</dd>" +
               "<dt>JSON</dt> <dd>Any valid JSON input.</dd>" +
               "</dl>"), :title => _("How values are validated")).html_safe}
  end

  def validator_type_selector f
     selectable_f f, :validator_type, options_for_select(LookupKey::VALIDATOR_TYPES, f.object.validator_type),{:include_blank => _("None")},
                { :disabled => (f.object.is_param && !f.object.override), :size => "col-md-8" ,
                  :onchange => 'validatorTypeSelected(this)',
                  :help_block => popover("Validator type",_("<dl>" +
                "<dt>List</dt> <dd>A list of the allowed values, specified in the Validator rule field.</dd>" +
                "<dt>Regexp</dt> <dd>Validates the input with the regular expression in the Validator rule field.</dd>" +
                "</dl>"), :title => _("Validation types")).html_safe}
  end

  def overridable_lookup_keys klass, host
    klass.class_params.override.where(:environment_classes => {:environment_id => host.environment}) + klass.lookup_keys
  end

  def hostgroup_key_with_diagnostic hostgroup, key
    value, origin = hostgroup.inherited_lookup_value key
    original_value = key.value_before_type_cast value
    diagnostic_helper = popover(_("Additional info"), _("<b>Description:</b> %{desc}<br><b>Type:</b> %{type}<br> <b>Matcher:</b> %{matcher}") % { :desc => key.description, :type => key.key_type, :matcher => origin})
    content_tag :div, :class => ['form-group', 'condensed'] do
    row_count = original_value.to_s.lines.count rescue 1
          text_area_tag("value_#{key.key}", original_value, :rows => row_count == 0 ? 1 : row_count,
                        :class => ['col-md-5'], :'data-property' => 'value', :disabled => true) +
          content_tag(:span, :class => "help-block") { diagnostic_helper }
         end
  end

  def host_key_with_diagnostic host, value_hash, key
     value_for_key = value_hash[key.id] && value_hash[key.id][key.key]
     value, matcher = value_for_key ? [value_for_key[:value], value_for_key[:element]] : [key.default_value, _("Default value")]
     original_value = key.value_before_type_cast value
     no_value = value.nil? && key.lookup_values.find_by_match("fqdn=#{host.fqdn}")

     diagnostic_class = []
     diagnostic_helper = popover(_("Additional info"), _("<b>Description:</b> %{desc}<br><b>Type:</b> %{type}<br> <b>Matcher:</b> %{matcher}") % { :desc => key.description, :type => key.key_type, :matcher => matcher})
     if no_value
       if key.required
         diagnostic_class << 'error'
         diagnostic_helper = popover(_('No value error'), _("Required parameter without value.<br/><b>Please override!</b> <br><br><b>Description:</b>: %s") % key.description)
       else
         diagnostic_class << 'warning'
         diagnostic_helper = popover(_('No value warning'), _("Optional parameter without value.<br/><i>Won\'t be given to Puppet.</i> <br><br><b>Description:</b> %s") % key.description)
       end
     end

     content_tag :div, :class => ['form-group', 'condensed'] + diagnostic_class do
      row_count = original_value.to_s.lines.count rescue 1
      text_area_tag("value_#{key.key}", original_value, :rows => row_count == 0 ? 1 : row_count,
                    :class => ['col-md-5'], :'data-property' => 'value', :disabled => true) +
      content_tag(:span, :class => "help-block") { diagnostic_helper }
     end
  end

end
