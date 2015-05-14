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

  def include_javascript
    javascript 'provisioning_template', 'ace/ace',
               'ace/theme-twilight', 'ace/theme-dawn', 'ace/theme-clouds', 'ace/theme-textmate',
               'ace/mode-diff', 'diff', 'ace/mode-ruby', 'ace/keybinding-vim', 'ace/keybinding-emacs'
  end

  def show_default?
    rights = Taxonomy.enabled_taxonomies.select { |taxonomy| User.current.can?("create_#{taxonomy}".to_sym) }
    rights.all? && !rights.blank?
  end

  def default_template_description
    if locations_only?
      _("Default templates are automatically added to new locations")
    elsif organizations_only?
      _("Default templates are automatically added to new organizations")
    elsif locations_and_organizations?
      _("Default templates are automatically added to new organizations and locations")
    end
  end

  def permitted_actions(template)
    actions = [display_link_if_authorized(_('Clone'), template_hash_for_member(template, 'clone_template'))]

    if template.locked?
      confirm = [
        _("You are about to unlock a locked template."),

        if locations_only?
          _("This is for every location that uses it.")
        elsif organizations_only?
          _("This is for every organization that uses it.")
        elsif locations_and_organizations?
          _("This is for every location and organization that uses it.")
        end,

        if template.vendor
          _("It is not recommended to unlock this template, as it is provided by %{vendor} and may be overwritten. Please consider cloning it instead.") %
            {:vendor => template.vendor}
        end,

        _("Continue?")
      ].compact

      actions << display_link_if_authorized(_('Unlock'), template_hash_for_member(template, 'unlock'),
                                            {:confirm => confirm.join(" "), :style => 'color: red'})

    else
      actions << display_link_if_authorized(_('Lock'), template_hash_for_member(template, 'lock'))
      actions << display_delete_if_authorized(template_hash_for_member(template).
         merge(:auth_object => template, :authorizer => authorizer, :permission => "destroy_#{@type_name_plural}"),
         :confirm => _("Delete %s?") % template)
    end
  end

  private

  def locations_only?
    SETTINGS[:locations_enabled] && !SETTINGS[:organizations_enabled]
  end

  def organizations_only?
    SETTINGS[:organizations_enabled] && !SETTINGS[:locations_enabled]
  end

  def locations_and_organizations?
    SETTINGS[:locations_enabled] && SETTINGS[:organizations_enabled]
  end
end

