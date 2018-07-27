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
    rights.all? && rights.present?
  end

  def safemode_methods
    @@safemode_methods ||= begin
      objects = ObjectSpace.each_object(Class).select{|x| x < Safemode::Jail }
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
    @@safemode_variables ||= Foreman::Renderer.config.allowed_variables.sort.map{|x| "@#{x}"}.join(' ')
  end

  def locked_warning(template)
    warning_text = _("This template is locked. You may only change the\
                     associations. Please %s it to customize.") %
                    link_to(_('clone'),
                            template_hash_for_member(template, 'clone_template'))

    alert(:class => 'alert-warning', :text => warning_text.html_safe)
  end
end
