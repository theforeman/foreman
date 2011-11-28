module OperatingsystemsHelper
  include CommonParametersHelper

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
    "#{icon(record, opts)} #{record}".html_safe
  end

end
