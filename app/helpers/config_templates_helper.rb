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
end
