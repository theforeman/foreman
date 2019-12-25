module ProvisioningTemplatesHelper
  def combination(template)
    template.template_combinations.map do |comb|
      str = []
      str << (comb.hostgroup_id.nil? ? _("None") : comb.hostgroup.to_s)
      str << (comb.environment_id.nil? ? _("None") : comb.environment.to_s)
      str.join(" / ")
    end.to_sentence
  end

  def template_kind(template)
    template.template_kind
  end

  def permitted_actions(template)
    actions = [
      display_link_if_authorized(_('Clone'), template_hash_for_member(template, 'clone_template')),
      display_link_if_authorized(_('Export'), template_hash_for_member(template, 'export'), { :data => { :no_turbolink => true } }),
    ]

    if template.is_a?(ReportTemplate) && !template.snippet
      actions.unshift(display_link_if_authorized(_('Generate'), template_hash_for_member(template, 'generate').merge(:authorizer => authorizer, :auth_object => template), { :data => { :no_turbolink => true } }))
    end

    if template.locked?
      confirm = [
        _("You are about to unlock a locked template."),
        _("This is for every location and organization that uses it."),
        if template.vendor
          _("It is not recommended to unlock this template, as it is provided by %{vendor} and may be overwritten. Please consider cloning it instead.") %
            {:vendor => template.vendor}
        end,

        _("Continue?"),
      ].compact

      actions << display_link_if_authorized(_('Unlock'), template_hash_for_member(template, 'unlock'),
        {:data => {:confirm => confirm.join(" ")}, :style => 'color: red'})

    else
      actions << display_link_if_authorized(_('Lock'), template_hash_for_member(template, 'lock'))
      actions << display_delete_if_authorized(template_hash_for_member(template).
         merge(:auth_object => template, :authorizer => authorizer, :permission => "destroy_#{@type_name_plural}"),
        :data => {:confirm => _("Delete %s?") % template})
    end
  end

  def pxe_with_building_hosts?(template)
    kinds = ["PXELinux", "PXEGrub"]
    template.respond_to?(:template_kind) &&
      template.respond_to?(:operatingsystem_ids) &&
      template.template_kind.present? &&
      kinds.include?(template.template_kind.name) &&
      building_hosts(template).any?
  end

  def building_hosts(template)
    Host.where(:build => true, :operatingsystem_id => template.operatingsystem_ids)
  end

  def building_hosts_path(template)
    oses = template.operatingsystem_ids.map { |id| "os_id = #{id}" }.join(" or ")
    hosts_path(:search => "build = true and ( #{oses} )")
  end

  def how_templates_are_determined
    alert(:class => 'alert-info', :header => 'How templates are determined',
          :text => ('<p>' + _("When editing a template, you must assign a list \
of operating systems which this template can be used with. Optionally, you can \
restrict a template to a list of host groups and/or environments.") + '</p>' +
'<p>' + _("When a Host requests a template (e.g. during provisioning), Foreman \
will select the best match from the available templates of that type, in the \
following order:") + '</p>' + '<ul>' +
    '<li>' + _("Host group and Environment") + '</li>' +
    '<li>' + _("Host group only") + '</li>' +
    '<li>' + _("Environment only") + '</li>' +
    '<li>' + _("Operating system default") + '</li>' +
    '</ul>' +
    (_("The final entry, Operating System default, can be set by editing the %s page.") %
     (link_to _("Operating System"), operatingsystems_path))).html_safe)
  end
end
