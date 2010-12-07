module OperatingsystemsHelper
  include CommonParametersHelper

  # displays release name on debian based distributions on operating system edit page.
  def show_release
    update_page do |page|
      page << "if (value == 'Debian') {"
      page[:release_name].show
      page[:release_name].highlight
      page << "} else {"
      page[:release_name].hide
      page << "}"
    end
  end

  # remove nested template_kind attribute from the attribute hash
  # this is a workaround to nested attributes, as we dont know the id's of the object.
  def param_field param
    param.gsub("[template_kind_id]","")
  end

  def span_id obj
    obj.config_template.nil? ? "template_new_os_default_templates" : "templates_#{obj.object_id}"
  end

end
