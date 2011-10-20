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

  def icon record, opts = {}
    return "" if record.blank? or record.name.blank?
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
      return "" if record.family.blank?
      record.family
    end

    image_tag(family+".png", opts) + " "
  end

  def os_name record, opts = {}
    "#{icon(record, opts)} #{h(record)}"
  end

end
