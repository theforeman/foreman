module ConfigTemplatesHelper
  def combination(template)
    template.template_combinations.map do |comb|
      str = []
      str << (comb.hostgroup_id.nil? ? _("None") : comb.hostgroup.to_s)
      str << (comb.environment_id.nil? ? _("None") : comb.environment.to_s)
      str.join(" / ")
    end.to_sentence
  end

  def include_javascript
    javascript 'config_template', 'ace/ace',
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

  def permitted_actions(config_template)
    actions = [display_link_if_authorized(_('Clone'), hash_for_clone_config_template_path(:id => config_template))]

    if config_template.locked?
      confirm = [
        _("You are about to unlock a locked template."),

        if locations_only?
          _("This is for every location that uses it.")
        elsif organizations_only?
          _("This is for every organization that uses it.")
        elsif locations_and_organizations?
          _("This is for every location and organization that uses it.")
        end,

        if config_template.vendor
          _("It is not recommended to unlock this template, as it is provided by %{vendor} and may be overwritten. Please consider cloning it instead.") %
            {:vendor => config_template.vendor}
        end,

        _("Continue?")
      ].compact

      actions << display_link_if_authorized(_('Unlock'), hash_for_unlock_config_template_path(:id => config_template),
                                            {:confirm => confirm.join(" "), :style => 'color: red'})

    else
      actions << display_link_if_authorized(_('Lock'), hash_for_lock_config_template_path(:id => config_template))
      actions << display_delete_if_authorized(hash_for_config_template_path(:id => config_template.to_param).
         merge(:auth_object => config_template, :authorizer => authorizer, :permission => 'destroy_templates'),
         :confirm => _("Delete %s?") % config_template)
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

