module OperatingsystemsHelper
  include CommonParametersHelper

  def label(record)
    return "" if record.blank? || record.name.blank?
    record.to_label
  end

  def icon(record, opts = {})
    return "" if record.blank? || record.name.blank?
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
               "Freebsd"
             when /aix/i
               "AIX"
             when /Junos/i
               "Junos"
             when /VRP/i
               "VRP"
             when /OracleLinux/i
               "OracleLinux"
             when /CoreOS|ContainerLinux|Container Linux/i
               "Coreos"
             when /RancherOS/i
               "Rancheros"
             when /NXOS/i
               "NXOS"
             when /XenServer/i
               "Xenserver"
             else
               return "" if record.family.blank?
               record.family
             end
    return image_path(family + ".png") if opts[:path]

    image_tag(family + ".png", opts) + " "
  end

  def os_name(record, opts = {})
    icon(record, opts).html_safe << record.to_label
  end

  def os_habtm_family(type, obj)
    result = type.where(:os_family => obj.family)
    result.empty? ? type : result
  end
end
