module OperatingsystemsHelper
  include CommonParametersHelper

  # displays release name on debian based distributions on operating system edit page.
  def show_release
    update_page do |page|
      page << "if (value == 'Debian' || value == 'Solaris') {"
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

  def icon record, opts = {}
    return "" if record.blank? or record.name.blank? or record.family.blank?
    family = case record.name
    when /fedora/i
      "Fedora"
    when /ubuntu/i
      "Ubuntu"
    when /solaris|sunos/i
      "Solaris"
    when /darwin/i
      "Darwin"
    when /centos/i
      "Centos"
    when /scientific/i
      "Scientific"
    when /SLC/i
      "SLC"
    else
      record.family
    end

    image_tag(family+".png", opts) + " "
  end

  def os_name record, opts = {}
    "#{icon(record, opts)} #{h(record)}"
  end

end
