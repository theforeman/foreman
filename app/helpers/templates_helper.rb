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

  def mount_report_template_input(input_value)
    return if input_value.nil?

    input = input_value.template_input
    controller = input.resource_type&.tableize

    mount_react_component('TemplateInput', "#template-input-#{input.id}", {
      value: input_value.value.to_s,
      required: input.required,
      template: 'report_template_report',
      description: input.description,
      supportedTypes: TemplateInput::VALUE_TYPE,
      resourceType: controller,
      id: input.id,
      useKeyShortcuts: false,
      url: search_path(controller),
      label: input.name,
      type: input.value_type,
      initialError: input_value.errors[:value].join("\n").presence,
      resourceTypes: Hash[Permission.resources.map { |d| [d.tableize.to_s, d] }],
    }.to_json)
  end

  def multiple_template_actions(templates)
    actions = []
    actions << [_('Delete Templates'), send("multiple_destroy_#{templates}_path"), true] if authorized_for(controller: :templates, action: :destroy)
    actions
  end

  def multiple_template_actions_select(templates)
    select_action_button(_('Select Action'), { id: 'submit_multiple' },
      multiple_template_actions(templates).map do |action|
        # If the action array has 3 entries, the third one is whether to use a modal dialog or not
        modal = (action.size == 3) ? action[2] : true
        if modal
          link_to_function(action[0], "tfm.templates.table.buildModal(this, '#{action[1]}')", :'data-dialog-title' => _("%s - The following templates are about to be changed") % action[0])
        else
          link_to_function(action[0], "tfm.templates.table.buildRedirect('#{action[1]}')")
        end
      end.flatten
    )
  end
end
