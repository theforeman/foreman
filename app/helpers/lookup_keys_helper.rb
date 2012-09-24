module LookupKeysHelper

  def remove_child_link(name, f, opts = {})
    opts[:class] = [opts[:class], "remove_nested_fields"].compact.join(" ")
    f.hidden_field(opts[:method]||:_destroy) + link_to_function(name, "remove_child_node(this);" , opts)
  end

  def add_child_link(name, association, opts = {})
    opts[:class] = [opts[:class], "add_nested_fields btn btn-small btn-success"].compact.join(" ")
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
      select_f f, :puppetclass_id, [Puppetclass.find(params["puppetclass_id"])], :id, :to_label, {}, {:label => "Puppet class", :disabled => true}
    elsif f.object.is_param && f.object.param_class
      field(f, :puppetclass_id, :label => 'Puppet Class') do
        content_tag(:input, nil, :value => f.object.param_class, :type => 'text', :disabled => true)
      end
    else # new smart-var with no particular context
         # Give a select for choosing the parent puppetclass
      select_f(f, :puppetclass_id, Puppetclass.all, :id, :to_label, { :include_blank => 'None' }, {:label => "Puppet class"})
    end unless @puppetclass # nested smart-vars form in a tab of puppetclass/_form: no edition allowed, and the puppetclass is already visible as a context
  end

  def param_type_selector f
    selectable_f f, :key_type, options_for_select(LookupKey::KEY_TYPES, f.object.key_type),{},
               { :disabled => (f.object.is_param && !f.object.override), :label => "Type", :class => "medium",
                 :help_inline => popover("?","<dl>
               <dt>String</dt> <dd>Everything is taken as a string.</dd>
               <dt>Boolean</dt> <dd>Common representation of boolean values are accepted.</dd>
               <dt>Integer</dt> <dd>Integer numbers only, can be negative.</dd>
               <dt>Real</dt> <dd>Accept any numerical input.</dd>
               <dt>Array</dt> <dd>A valid JSON or YAML input, that must evaluate to an array.</dd>
               <dt>Hash</dt> <dd>A valid JSON or YAML input, that must evaluate to an object/map/dict/hash.</dd>
               <dt>YAML</dt> <dd>Any valid YAML input.</dd>
               <dt>JSON</dt> <dd>Any valid JSON input.</dd>
               </dl>", :title => "How values are validated").html_safe}
  end

  def validator_type_selector f
     selectable_f f, :validator_type, options_for_select(LookupKey::VALIDATOR_TYPES, f.object.validator_type),{:include_blank => true},
                { :disabled => (f.object.is_param && !f.object.override), :label => "Validator Type", :class => "medium",
                  :help_inline => popover("?","<dl>
                <dt>List</dt> <dd>A list of the allowed values, specified in the Validator rule field.</dd>
                <dt>Regexp</dt> <dd>Validates the input with the regular expression in the Validator rule field.</dd>
                </dl>", :title => "Validation types").html_safe}
   end

end
