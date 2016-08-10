module FormHelper
  def text_f(f, attr, options = {})
    field(f, attr, options) do
      addClass options, "form-control"
      options[:focus_on_load] ||= attr.to_s == 'name'
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

  def button_input_group(content, options = {}, glyph = nil)
    options[:type] ||= 'button'
    options[:herf] ||= '#'
    options[:class] ||= 'btn btn-default'
    content_tag :span, class: 'input-group-btn' do
      content_tag :button, content, options  do
        content_tag :span,content, :class => glyph
      end
    end
  end

  def password_f(f, attr, options = {})
    unset_button = options.delete(:unset)
    password_field_tag(:fakepassword, nil, :style => 'display: none') +
        field(f, attr, options) do
          options[:autocomplete]   ||= 'off'
          options[:placeholder]    ||= password_placeholder(f.object, attr)
          options[:disabled] = true if unset_button
          addClass options, 'form-control'
          pass = f.password_field(attr, options) +
              '<span class="glyphicon glyphicon-warning-sign input-addon"
             title="'.html_safe + _('Caps lock ON') +
              '" style="display:none"></span>'.html_safe
          if unset_button
            button = button_input_group '', {:id => 'disable-pass-btn', :onclick => "toggle_input_group(this)", :title => _("Change the password")}, 'glyphicon glyphicon-pencil'
            input_group pass, button
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
    if associations.count > 5
      associated_obj = klass.send(ActiveModel::Naming.plural(associations.first))
      selected_ids = associated_obj.select("#{associations.first.class.table_name}.id").map(&:id)
      multiple_selects(f, attr, associations, selected_ids, options, html_options)
    else
      field(f, attr, options) do
        authorized_edit_habtm klass, associations, options[:prefix], html_options
      end
    end
  end

  # add hidden field for options[:disabled]
  def multiple_selects(f, attr, associations, selected_ids, options = {}, html_options = {})
    options.merge!(:size => "col-md-10")
    authorized = AssociationAuthorizer.authorized_associations(associations).all

    # select2.js breaks the multiselects disabled items location
    # http://projects.theforeman.org/issues/12028
    html_options["class"] ||= ""
    html_options["class"] += " without_select2"
    html_options["class"].strip!

    unauthorized = selected_ids.blank? ? [] : selected_ids - authorized.map(&:id)
    field(f, attr, options) do
      attr_ids = (attr.to_s.singularize+"_ids").to_sym
      hidden_fields = ''
      html_options["data-useds"] ||= "[]"
      JSON.parse(html_options["data-useds"]).each do |disabled_value|
        hidden_fields += f.hidden_field(attr_ids, :multiple => true, :value => disabled_value, :id=>'')
      end
      unauthorized.each do |unauthorized_value|
        hidden_fields += f.hidden_field(attr_ids, :multiple => true, :value => unauthorized_value, :id=>'')
      end
      hidden_fields + f.collection_select(attr_ids, authorized.sort_by { |a| a.to_s },
                                          :id, :to_label, options.merge(:selected => selected_ids),
                                          html_options.merge(:multiple => true))
    end
  end

  def line_count(f, attr)
    rows = f.object.try(attr).to_s.lines.count rescue 1
    rows == 0 ? 1 : rows
  end

  def radio_button_f(f, attr, options = {})
    text = options.delete(:text)
    value = options.delete(:value)
    label_tag('', :class=>"radio-inline") do
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
      blank_option.instance_eval('undef to_s') if method.to_s == 'to_s' || id.to_s == 'to_s'
      array.insert(0, blank_option)
    end

    select_options[:disabled] = '' if select_options[:disabled] == include_blank
    html_options.merge!(:disabled => true) if disable_button_enabled

    html_options.merge!(:size => 'col-md-10') if html_options[:multiple]
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
    html_options.merge!(:size => 'col-md-10') if html_options[:multiple]
    field(f, attr, html_options) do
      addClass html_options, "form-control"
      f.select attr, array, select_options, html_options
    end
  end

  def file_field_f(f, attr, options = {})
    field(f, attr, options) do
      f.file_field attr, options
    end
  end

  def autocomplete_f(f, attr, options = {})
    field(f, attr, options) do
      path = options.delete(:path) || send("#{f.object.class.pluralize.underscore}_path") if options[:full_path].nil?
      auto_complete_search(attr,
                           f.object.send(attr).try(:squeeze, " "),
                           options.merge(
                               :placeholder => _("Filter") + ' ...',
                               :path        => path,
                               :name        => "#{f.object_name}[#{attr}]"
                           )
      ).html_safe
    end
  end

  def form_to_submit_id(f)
    object = f.object.respond_to?(:to_model) ? f.object.to_model : f.object
    key = if object.present?
            object.persisted? ? :update : :create
          else
            :submit
          end
    model = if object.class.respond_to?(:humanize_class_name)
              object.class.humanize_class_name.downcase
            elsif object.class.respond_to?(:model_name)
              object.class.model_name.human.downcase
            else
              f.object_name.to_s
            end.gsub(/\W+/, '_')
    "aid_#{key}_#{model}"
  end

  def submit_or_cancel(f, overwrite = false, args = { })
    args[:cancel_path] ||= send("#{controller_name}_path")
    content_tag(:div, :class => "clearfix") do
      content_tag(:div, :class => "form-actions") do
        text    = overwrite ? _("Overwrite") : _("Submit")
        options = {}
        options[:class] = "btn btn-#{overwrite ? 'danger' : 'primary'} remove_form_templates"
        options.merge! :'data-id' => form_to_submit_id(f) unless options.has_key?(:'data-id')
        link_to(_("Cancel"), args[:cancel_path], :class => "btn btn-default") + " " + f.submit(text, options)
      end
    end
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
      args.last[:html] = {:class=>"form-horizontal well"}.merge(args.last[:html]||{})
    else
      args << {:html=>{:class=>"form-horizontal well"}}
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
    help_inline = error.empty? ? inline : content_tag(:span, error.to_sentence.html_safe, :class => 'error-message')
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

  def add_label options, f, attr
    label_size = options.delete(:label_size) || "col-md-2"
    required_mark = check_required(options, f, attr)
    label = options[:label] == :none ? '' : options.delete(:label)
    label ||= ((clazz = f.object.class).respond_to?(:gettext_translation_for_attribute_name) &&
        s_(clazz.gettext_translation_for_attribute_name attr)) if f
    label = label.present? ? label_tag(attr, "#{label}#{required_mark}", :class => label_size + " control-label") : ''
    label
  end

  def check_required options, f, attr
    required = options.delete(:required) # we don't want to use html5 required attr so we delete the option
    return ' *' if required.nil? ? is_required?(f, attr) : required
  end

  def blank_or_inherit_f(f, attr)
    return true unless f.object.respond_to?(:parent_id) && f.object.parent_id
    inherited_value   = f.object.send(attr).try(:name_method)
    inherited_value ||= _("no value")
    _("Inherit parent (%s)") % inherited_value
  end

  def link_to_remove_fields(name, f, options = {})
    f.hidden_field(:_destroy) + link_to_function(icon_text('close', name, :kind => 'pficon'), "remove_fields(this)", options.merge(:title => _("Remove Parameter")))
  end

  # Creates a link to a javascript function that creates field entries for the association on the web page
  # +name+       : String containing links's text
  # +f+          : FormBuiler object
  # +association : The field are created to allow entry into this association
  # +partial+    : String containing an optional partial into which we render
  def link_to_add_fields(name, f, association, partial = nil, options = {})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render((partial.nil? ? association.to_s.singularize + "_fields" : partial), :f => builder)
    end
    options[:class] = "btn btn-primary #{options[:class]}"
    link_to_function(name, ("add_fields('#{options[:target]}', '#{association}', '#{escape_javascript(fields)}')").html_safe, options)
  end

  def field(f, attr, options = {})
    table_field = options.delete(:table_field)
    error       = options.delete(:error) || f.object.errors[attr] if f && f.object.respond_to?(:errors)
    help_inline = help_inline(options.delete(:help_inline), error)
    size_class  = options.delete(:size) || "col-md-4"
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
            if options[:fullscreen]
              content_tag(:div, yield.html_safe + fullscreen_input, :class => "input-group")
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
end
