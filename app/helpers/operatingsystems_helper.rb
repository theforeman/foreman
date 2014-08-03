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
    when /archlinux/i
      "Archlinux"
    when /altlinux/i
      "Altlinux"
    when /gentoo/i
      "Gentoo"
    when /SLC/i
      "SLC"
    when /FreeBSD/i
      "FreeBSD"
    when /aix/i
      "AIX"
    when /Junos/i
      "Junos"
    when /OracleLinux/i
      "OracleLinux"
    else
      return "" if record.family.blank?
      record.family
    end

    image_tag(family+".png", opts) + " "
  end

  def os_name record, opts = {}
    icon(record, opts).html_safe << trunc(record.to_label)
  end

  def os_habtm_family type, obj
    result = type.where(:os_family => obj.family)
    result.empty? ? type : result
  end

end
