module ConfigTemplatesHelper
  def combination template
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

  def association_text()
    content_tag(:p, _("When editing a Template, you must assign a list of Operating Systems which this Template can be used with. Optionally, you can restrict a template to a list of Hostgroups and/or Environments")) +
    content_tag(:p, _("When a Host requests a template (e.g. during provisioning), Foreman will select the best match from the available templates of that type, in the following order:")) +
    (content_tag :ul do
      content_tag(:li, _("Host group and Environment")) +
      content_tag(:li, _("Host group only"))            +
      content_tag(:li, _("Environment only"))           +
      content_tag(:li, _("Operating system default"))
    end) +
    (_("The final entry, Operating System default, can be set by editing the %s page.") % (link_to _("Operating System"), operatingsystems_path)).html_safe
  end

end
