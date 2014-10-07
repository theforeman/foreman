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

  def permitted_actions(config_template)
    actions = [display_link_if_authorized(_('Clone'), hash_for_clone_config_template_path(:id => config_template))]

    if config_template.locked?
      # Default templates aren't actually unlockable - show the link as gray and no confirm dialog.
      opts = config_template.default ? {:style => "color: gray"} : {:confirm =>  _("You are about to unlock a locked " \
        "template -- this is for every organization and location that uses it. Continue?"), :style => "color: red"}

      actions << display_link_if_authorized(_('Unlock'), hash_for_unlock_config_template_path(:id => config_template), opts)

    else
      actions << display_link_if_authorized(_('Lock'), hash_for_lock_config_template_path(:id => config_template))
      actions << display_delete_if_authorized(hash_for_config_template_path(:id => config_template.to_param).
         merge(:auth_object => config_template, :authorizer => authorizer, :permission => 'destroy_templates'),
         :confirm => _("Delete %s?") % config_template)
    end
  end
end

