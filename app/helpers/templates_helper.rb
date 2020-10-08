module TemplatesHelper
  def snippet_message(template)
    return unless template.snippet
    alert(:class => 'alert-info', :header => '',
          :text => _("Not relevant for snippet"))
  end

  def default_template_description
    _("Default templates are automatically added to new organizations and locations")
  end

  def show_default?
    User.current.can?(:create_oragnizations) && User.current.can?(:create_locations)
  end

  def safemode_methods
    @@safemode_methods ||= begin
      objects = ObjectSpace.each_object(Class).select { |x| x < Safemode::Jail }
      objects_with_methods = objects.map do |obj|
        [obj.name.gsub(/::Jail$/, ''), obj.allowed_methods.sort.join(' ')]
      end
      objects_with_methods.uniq.sort_by(&:first)
    end
  end

  def safemode_helpers
    @@safemode_helpers ||= Foreman::Renderer.config.allowed_helpers.sort.join(' ')
  end

  def safemode_variables
    @@safemode_variables ||= Foreman::Renderer.config.allowed_variables.sort.map { |x| "@#{x}" }.join(' ')
  end

  def locked_warning(template)
    warning_text = _("This template is locked. You may only change the\
                     associations. Please %s it to customize.") %
                    link_to(_('clone'),
                      template_hash_for_member(template, 'clone_template'))

    alert(:class => 'alert-warning', :text => warning_text.html_safe)
  end

  def template_input_header(f, template)
    header = _('Template input')
    unless template.locked?
      header += ' ' + remove_child_link('x', f, {:rel => 'twipsy', :'data-title' => _('remove template input'), :'data-placement' => 'left',
                                                 :class => 'fr badge badge-danger'})
    end
    header.html_safe
  end

  def template_input_types_options(keys = TemplateInput::TYPES.keys)
    keys.map!(&:to_s)
    TemplateInput::TYPES.select { |k, _| keys.include?(k.to_s) }.map { |key, name| [_(name), key] }
  end

  def hide_resource_type_input(obj)
    'hide' unless obj.value_type == 'search'
  end

  def template_input_f(f, options = {})
    input_value = f.object
    input = input_value.template_input

    options.reverse_merge!(label: input.name, id: input.name, label_help: input.description.presence, required: input.required)

    if input.options.present?
      selectable_f(f, :value, input.options_array, { include_blank: !input.required }, options)
    elsif input.value_type == 'plain' || input.value_type.nil?
      textarea_f(f, :value, options.merge(rows: 2, class: input.hidden_value? ? 'masked-input' : ''))
    else
      input_type = input.value_type
      if input_type == 'date'
        input_type = 'dateTime'
        options[:label_help] ||= 'Format is yyyy-MM-dd HH-mm-ss'
      elsif input_type == 'search'
        input_type = 'autocomplete'
        resource_type = input.resource_type&.tableize
        options.merge!(resource_type: resource_type, use_key_shortcuts: false, url: search_path(resource_type))
      end
      react_form_input(input_type, f, :value, options)
    end
  end
end
