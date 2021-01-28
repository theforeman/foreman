module FormHelper
  def text_f(f, attr, options = {})
    field(f, attr, options) do
      addClass options, "form-control"
      options[:focus_on_load] = true if options[:focus_on_load].nil? && attr.to_s == 'name'
      f.text_field attr, options
    end
  end

  def textarea_f(f, attr, options = {})
    field(f, attr, options) do
      options[:rows] = line_count(f, attr) if options[:rows] == :auto
      addClass options, "form-control"
      f.text_area(attr, options)
    end
  end

  def password_f(f, attr, options = {})
    unset_button = options.delete(:unset)
    value = f.object[attr] if options.delete(:keep_value)
    password_field_tag(:fakepassword, value, :style => 'display: none', :autocomplete => 'new-password-fake') +
        field(f, attr, options) do
          options[:autocomplete]   ||= 'new-password'
          options[:placeholder]    ||= password_placeholder(f.object, attr)
          options[:disabled] = true if unset_button
          options[:value] = value if value.present?
          addClass options, 'form-control'
          pass = f.password_field(attr, options) +
              '<span class="glyphicon glyphicon-warning-sign input-addon"
             title="'.html_safe + _('Caps lock ON') +
              '" style="display:none"></span>'.html_safe
          if unset_button
            button = link_to_function(icon_text("edit", "", :kind => "pficon"), 'toggle_input_group(this)', {:id => 'disable-pass-btn', :class => 'btn btn-default', :title => _("Change the password")})
            input_group(pass, input_group_btn(button))
          else
            pass
          end
        end
  end

  def checkbox_f(f, attr, options = {}, checked_value = "1", unchecked_value = "0")
    text = options.delete(:help_text)
    inline = options.delete(:help_inline)
    field(f, attr, options) do
      help_inline = inline.blank? ? '' : content_tag(:span, inline, :class => "help-inline")
      f.check_box(attr, options, checked_value, unchecked_value) + " #{text} " + help_inline.html_safe
    end
  end

  def multiple_checkboxes(f, attr, klass, associations, options = {}, html_options = {})
    association_name = attr || ActiveModel::Naming.plural(associations)
    associated_obj = klass.send(association_name)
    selected_ids = options.delete(:selected_ids) || associated_obj.map(&:id)
    multiple_selects(f, attr, associations, selected_ids, options, html_options)
  end

  # add hidden field for options[:disabled]
  def multiple_selects(f, attr, associations, selected_ids, options = {}, html_options = {})
    options[:size] = "col-md-10"
    case attr
      when :organizations
        klass = Organization
      when :locations
        klass = Location
      else
        klass = nil
    end
    authorized = AssociationAuthorizer.authorized_associations(associations.reorder(nil), klass).all

    # select2.js breaks the multiselects disabled items location
    # http://projects.theforeman.org/issues/12028
    html_options["class"] ||= ""
    html_options["class"] += " without_select2"
    html_options["class"].strip!

    unauthorized = selected_ids.blank? ? [] : selected_ids - authorized.map(&:id)
    field(f, attr, options) do
      attr_ids = attr.to_s
      attr_ids = (attr_ids.singularize + '_ids').to_sym unless attr_ids.end_with?('_ids')
      hidden_fields = ''
      html_options["data-useds"] ||= "[]"
      JSON.parse(html_options["data-useds"]).each do |disabled_value|
        hidden_fields += f.hidden_field(attr_ids, :multiple => true, :value => disabled_value, :id => '')
      end
      unauthorized.each do |unauthorized_value|
        hidden_fields += f.hidden_field(attr_ids, :multiple => true, :value => unauthorized_value, :id => '')
      end
      hidden_fields + f.collection_select(attr_ids, authorized.sort_by { |a| a.to_s },
        :id, options.delete(:object_label_method) || :to_label, options.merge(:selected => selected_ids),
        html_options.merge(:multiple => true))
    end
  end

  def line_count(f, attr)
    rows = f.object.try(attr).to_s.lines.count rescue 1
    (rows == 0) ? 1 : rows
  end

  def radio_button_f(f, attr, options = {})
    text = options.delete(:text)
    value = options.delete(:value)
    label_tag('', :class => "radio-inline") do
      f.radio_button(attr, value, options) + " #{text} "
    end
  end

  def select_f(f, attr, array, id, method, select_options = {}, html_options = {})
    array = array.to_a.dup
    disable_button = select_options.delete(:disable_button)
    include_blank = select_options.delete(:include_blank)
    disable_button_enabled = select_options.delete(:disable_button_enabled)
    user_set = !!select_options.delete(:user_set)

    if include_blank
      blank_value = include_blank.is_a?(TrueClass) ? nil : include_blank
      blank_option = OpenStruct.new({id => '', method => blank_value })
      # if the method is to_s, OpenStruct will respond with its own version.
      # in this case, I need to undefine its own alias to to_s, and use the attribute
      # that was defined in the struct.
      blank_option.instance_eval('undef to_s', __FILE__, __LINE__) if method.to_s == 'to_s' || id.to_s == 'to_s'
      array.insert(0, blank_option)
    end

    select_options[:disabled] = '' if select_options[:disabled] == include_blank
    html_options[:disabled] = true if disable_button_enabled

    html_options[:size] = 'col-md-10' if html_options[:multiple]
    field(f, attr, html_options) do
      addClass html_options, "form-control"

      collection_select = f.collection_select(attr, array, id, method, select_options, html_options)

      if disable_button
        button_part =
          content_tag :span, class: 'input-group-btn' do
            content_tag(:button, disable_button, :type => 'button', :href => '#',
                        :name => 'is_overridden_btn',
                        :onclick => "disableButtonToggle(this)",
                        :class => 'btn btn-default btn-can-disable' + (disable_button_enabled ? ' active' : ''),
                        :data => { :toggle => 'button', :explicit => user_set })
          end

        input_group collection_select, button_part
      else
        collection_select
      end
    end
  end

  def addClass(options = {}, new_class = '')
    options[:class] = "#{new_class} #{options[:class]}"
  end

  def input_group(*controls)
    content_tag :div, class: 'input-group' do
      controls.map { |control_html| concat(control_html) }
    end
  end

  def input_group_btn(*controls)
    content_tag :span, class: 'input-group-btn' do
      controls.join(' ').html_safe
    end
  end

  def time_zone_select_f(f, attr, default_timezone, select_options = {}, html_options = {})
    field(f, attr, html_options) do
      addClass html_options, "form-control"
      f.time_zone_select(attr, [default_timezone], select_options, html_options)
    end
  end

  def selectable_f(f, attr, array, select_options = {}, html_options = {})
    html_options[:size] = 'col-md-10' if html_options[:multiple]
    field(f, attr, html_options) do
      form_select_f(f, attr, array, select_options, html_options)
    end
  end

  def selectable_f_inline(f, attr, array, select_options = {}, html_options = {})
    html_options[:size] = 'col-md-10' if html_options[:multiple]
    form_select_f(f, attr, array, select_options, html_options)
  end

  def spinner_button_f(f, caption, action, html_options = {})
    html_options[:class] ||= 'btn-default'
    html_options[:class] = "btn btn-spinner #{html_options[:class]}"
    caption = '<div class="caption">' + caption + '</div>'
    caption += hidden_spinner('', :id => html_options[:spinner_id], :class => html_options[:spinner_class])
    link_to_function(caption.html_safe, action, html_options)
  end

  def file_field_f(f, attr, options = {})
    if options[:file_name]
      html =  content_tag(:b) { options.delete(:file_name) }
      html += content_tag(:hr)
      html += content_tag(:div, :style => "margin-bottom: 10px") { _("Choose a new file:") }
    end
    field(f, attr, options) do
      (html || " ") + (f.file_field attr, options)
    end
  end

  # Returns an AutoComplete React input tailored for accessing a specified attribute (identified by +attr+) on an object
  # assigned to the form (identified by +f+). Additional properties on the input tag can be passed as a
  # hash with +options+. These options will be tagged onto the React Component as an props as in the example
  # shown.
  #
  # ==== Options
  # * Creates standard React props for the component.
  # * <tt>:url</tt> - path where the search results should be fetched from.
  # * <tt>:disabled</tt> - If set to true, the user will not be able to use this input.
  # * <tt>:search_query</tt> - Default search query.
  # * <tt>:use_key_shortcuts</tt> - If set to true, keyboard shortcuts are enabled on the field.
  #
  # ==== Examples
  #   form_for(@user) do |f|
  #     autocomplete_f(f, :country, url: api_countries_path, search_query: 'Czech')
  #   end
  #   # => <AutoComplete id="user_country" name="user[country]" url="/api/countries/auto_complete_country" searchQuery="Czech" />
  def autocomplete_f(f, attr, options = {})
    options.merge!(
      {
        url: options[:full_path] || (options[:path] || send("#{auto_complete_controller_name}_path")) + "/auto_complete_#{attr}",
        controller: options[:path] || auto_complete_controller_name,
        search_query: options[:search_query] || f.object&.search || '',
        use_key_shortcuts: options[:use_key_shortcuts] || false,
      }
    )

    react_form_input('autocomplete', f, attr, options)
  end

  def byte_size_f(f, attr, options = {})
    options[:class] = options[:class].to_s + ' byte_spinner' unless options[:disabled]
    options[:label_help] = _("When specifying custom value, add 'MB' or 'GB' at the end. Field is not case sensitive and MB is default if unspecified.")
    options[:help_block] ||= soft_limit_warning_block
    options[:help_block] += f.hidden_field(attr, :class => "real-hidden-value", :id => nil)

    text_f(f, attr, options)
  end

  def counter_f(f, attr, options = {})
    options[:class] = options[:class].to_s + ' counter_spinner' unless options[:disabled]
    options[:help_block] ||= soft_limit_warning_block

    text_f(f, attr, options)
  end

  def soft_limit_warning_block
    content_tag(:span, :class => 'maximum-limit hidden') do
      icon_text('warning-triangle-o',
        content_tag(:span, ' ' + _('Specified value is higher than recommended maximum'), :class => 'error-message'),
        :kind => 'pficon')
    end
  end

  def submit_or_cancel(f, overwrite = false, args = { })
    args[:cancel_path] ||= resource_path(controller_name)
    cancel_btn = args[:react_cancel_button] ? react_cancel_button(args) : link_to(_("Cancel"), args[:cancel_path], :class => "btn btn-default")
    content_tag(:div, :class => "clearfix") do
      content_tag(:div, :class => "form-actions") do
        text    = overwrite ? _("Overwrite") : _("Submit")
        options = options_for_submit_or_cancel(f, overwrite, args)
        f.submit(text, options) + " " + cancel_btn
      end
    end
  end

  def react_cancel_button(args)
    react_component('RedirectCancelButton', { :cancelPath => args[:cancel_path] })
  end

  def options_for_submit_or_cancel(f, overwrite, args)
    options = {}
    options[:disabled] = true if args[:disabled]
    options[:class] = "btn btn-#{overwrite ? 'danger' : 'primary'} remove_form_templates"
    options[:data] = args[:data] if args.key?(:data)
    options
  end

  def add_help_to_label(size_class, label, help_inline)
    label.html_safe +
        content_tag(:div, :class => size_class) do
          yield
        end.html_safe + help_inline.html_safe
  end

  def is_required?(f, attr)
    return false unless f && f.object.class.respond_to?(:validators_on)
    f.object.class.validators_on(attr).any? do |validator|
      options = validator.options.keys.map(&:to_s)
      validator.is_a?(ActiveModel::Validations::PresenceValidator) && !options.include?('if') && !options.include?('unless')
    end
  end

  def form_for(record_or_name_or_array, *args, &proc)
    if args.last.is_a?(Hash)
      args.last[:html] = {:class => "form-horizontal well"}.merge(args.last[:html] || {})
    else
      args << {:html => {:class => "form-horizontal well"}}
    end
    super record_or_name_or_array, *args, &proc
  end

  def number_f(f, attr, options = {})
    field(f, attr, options) do
      addClass options, "form-control"
      f.number_field attr, options
    end
  end

  def help_inline(inline, error)
    help_inline = error.empty? ? inline : content_tag(:span, error.to_sentence, :class => 'error-message')
    case help_inline
      when blank?
        ""
      when :indicator
        content_tag(:span, content_tag(:div, '', :class => 'hide spinner spinner-xs'),
          :class => 'help-block').html_safe
      else
        content_tag(:span, help_inline, :class => "help-block help-inline")
    end
  end

  def add_label(options, f, attr)
    return ''.html_safe if options[:label] == :none

    label_size = options.delete(:label_size) || "col-md-2"
    required_mark = check_required(options, f, attr)
    label = ''.html_safe + options.delete(:label)
    label = get_attr_label(f, attr).to_s.html_safe if label.empty?

    if options[:label_help].present?
      label += ' '.html_safe + popover("", options[:label_help], options[:label_help_options] || {})
    end
    label = label.present? ? label_tag(attr, label.to_s + required_mark.to_s, :class => label_size + " control-label") : ''
    label
  end

  def check_required(options, f, attr)
    required = options.delete(:required) # we don't want to use html5 required attr so we delete the option
    return ' *'.html_safe if required.nil? ? is_required?(f, attr) : required
  end

  def blank_or_inherit_f(f, attr, blank_value: _("no value"))
    return true unless f.object.respond_to?(:parent_id) && f.object.parent_id
    inherited_value   = f.object.send(attr)
    inherited_value   = inherited_value.name_method if inherited_value.present? && inherited_value.respond_to?(:name_method)
    inherited_value ||= blank_value
    _("Inherit parent (%s)") % inherited_value
  end

  def link_to_remove_fields(name, f, options = {})
    options[:title] ||= _("Remove Parameter")
    f.hidden_field(:_destroy) + link_to_function(icon_text('remove', name, :kind => 'pficon'), "remove_fields(this)", options)
  end

  # Creates a link to a javascript function that creates field entries for the association on the web page
  # +name+       : String containing links's text
  # +f+          : FormBuiler object
  # +association : The field are created to allow entry into this association
  # +partial+    : String containing an optional partial into which we render
  def link_to_add_fields(name, f, association, partial = nil, options = {})
    new_object = f.object.class.reflect_on_association(association).klass.new
    locals_option = options.delete(:locals) || {}
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render((partial.nil? ? association.to_s.singularize + "_fields" : partial),
        { :f => builder }.merge(locals_option))
    end
    options[:class] = link_to_add_fields_classes(options)
    link_to_function(name, "add_fields('#{options[:target]}', '#{association}', '#{escape_javascript(fields)}')".html_safe, options)
  end

  def field(f, attr, options = {})
    table_field = options.delete(:table_field)
    error       = options.delete(:error) || get_attr_error(f, attr)
    help_inline = help_inline(options.delete(:help_inline), error)
    help_inline += options[:help_inline_permanent] unless options[:help_inline_permanent].nil?
    size_class = options.delete(:size) || "col-md-4"
    wrapper_class = options.delete(:wrapper_class) || "form-group"

    label = options[:no_label] ? "" : add_label(options, f, attr)

    if table_field
      add_help_to_label(size_class, label, help_inline) do
        yield
      end.html_safe
    else
      help_block = content_tag(:span, options.delete(:help_block), :class => "help-block")

      content_tag(:div, :class => "clearfix") do
        content_tag(:div, :class => "#{wrapper_class} #{error.empty? ? '' : 'has-error'}",
                    :id => options.delete(:control_group_id)) do
          input = capture do
            if (group_btn = options.delete(:input_group_btn))
              input_group(yield.html_safe, input_group_btn(group_btn))
            else
              yield.html_safe
            end
          end
          add_help_to_label(size_class, label, help_inline) do
            input + help_block.html_safe
          end
        end.html_safe
      end
    end
  end

  def date_local_f(f, attr, options = {})
    react_form_input('date', f, attr, options)
  end

  def datetime_local_f(f, attr, options = {})
    react_form_input('dateTime', f, attr, options)
  end

  def orderable_select_f(f, attr, choices, select_options = {}, html_options = {})
    options = choices.collect { |choice| { label: choice[0], value: choice[1] } } if choices.is_a?(Array)
    options = choices.collect { |(key, val)| { label: val, value: key } } if choices.is_a?(Hash)
    input_props = select_options.merge(options: options)
    react_form_input('orderableSelect', f, attr, html_options.merge(input_props: input_props))
  end

  def react_form_input(type, f, attr, options = {})
    options[:label] ||= get_attr_label(f, attr)
    options[:error] ||= get_attr_error(f, attr)
    options[:error] = options[:error]&.to_sentence
    options[:required] = is_required?(f, attr) unless options.key?(:required)

    Tags::ReactInput.new(f.object_name, attr, self, options.merge(type: type, object: f.object)).render
  end

  def advanced_switch_f(default_text, switch_text)
    content_tag :div, :class => 'form-group' do
      content_tag(:div, '', :class => 'col-md-2 control-label') +
        content_tag(:div, :class => 'col-md-4') do
          content_tag(:i, '', :class => 'fa fa-angle-right') + ' ' +
            link_to(default_text, '#', :class => 'advanced_fields_switch', :'data-alternative-label' => switch_text)
        end
    end
  end

  private

  def get_attr_label(f, attr)
    if f.try(:object) && (clazz = f.object.class).respond_to?(:gettext_translation_for_attribute_name)
      s_(clazz.gettext_translation_for_attribute_name(attr)).titleize
    end
  end

  def get_attr_error(f, attr)
    f.object.errors[attr] if f&.object.respond_to?(:errors)
  end

  def form_select_f(f, attr, array, select_options = {}, html_options = {})
    addClass html_options, "form-control"
    f.select attr, array, select_options, html_options
  end

  def link_to_add_fields_classes(options = {})
    classes = "btn btn-default #{options[:class]}"
    classes << ' btn-primary' if options.fetch(:primary_button, true)
    classes
  end
end
