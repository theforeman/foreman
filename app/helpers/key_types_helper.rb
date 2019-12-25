module KeyTypesHelper
  def param_type_selector(f, only_inline_select = false, options = {})
    common_extra_options = { :size => "col-md-4", :class => "parameter_type_selection without_select2",
                 :label_help => _("<dl>" +
                   "<dt>String</dt> <dd>Everything turns into a string.</dd>" +
                   "<dt>Boolean</dt> <dd>Common representation of boolean values are accepted.</dd>" +
                   "<dt>Integer</dt> <dd>Integer numbers only, can be negative.</dd>" +
                   "<dt>Real</dt> <dd>Accept any numerical input.</dd>" +
                   "<dt>Array</dt> <dd>A valid JSON or YAML input, that must evaluate to an array.</dd>" +
                   "<dt>Hash</dt> <dd>A valid JSON or YAML input, that must evaluate to an object/map/dict/hash.</dd>" +
                   "<dt>YAML</dt> <dd>Any valid YAML input.</dd>" +
                   "<dt>JSON</dt> <dd>Any valid JSON input.</dd>" +
               "</dl>").html_safe,
                 :label_help_options => { :title => _("How values are validated") }}
    if lookup_keys_table?(f)
      common_extra_options[:disabled] = (f.object.puppet? && !f.object.override)
      common_extra_options[:size] = 'col-md-8'
    end
    method_for_select_f = only_inline_select ? 'selectable_f_inline' : 'selectable_f'

    send(method_for_select_f, f, :parameter_type,
      options_for_select(LookupKey::KEY_TYPES.map { |e| [_(e), e] }, f.object.parameter_type), {},
      common_extra_options.merge(options))
  end

  def lookup_keys_table?(f)
    f.object.class.table_name == 'lookup_keys'
  end
end
