module TemplatesHelper
  def snippet_message(template)
    return unless template.snippet
    alert(:class => 'alert-info', :header => '',
          :text => _("Not relevant for snippet"))
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

  def show_default?
    rights = Taxonomy.enabled_taxonomies.select { |taxonomy| User.current.can?("create_#{taxonomy}".to_sym) }
    rights.all? && !rights.blank?
  end

  def infobox_functions_and_macros(docs_section)
    alert(:class => 'alert-info', :header => '',
          :text => (_('Check out some %s') %
                    link_to(_('useful template functions and macros'),
                            documentation_url(docs_section))),
          :rel => 'external')
  end

  def locked_warning(template)
    warning_text = _("This template is locked. You may only change the\
                     associations. Please %s it to customize.") %
                    link_to(_('clone'),
                            template_hash_for_member(template, 'clone_template'))

    alert(:class => 'alert-warning', :text => warning_text.html_safe)
  end
end
