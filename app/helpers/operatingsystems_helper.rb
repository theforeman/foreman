module OperatingsystemsHelper
  include CommonParametersHelper

  def label(record)
    return "" if record.blank? || record.name.blank?
    record.to_label
  end

  # Return OS icon image tag. Stub is used in some cases because
  # of legal requirements. Make sure to get legal advice prior
  # putting any logos into our git repository.
  def icon(record, opts = {})
    return "" if record.blank? || record.name.blank?
    size = opts[:size] ||= '16x16'
    name = case record.name
           when /fedora/i
             "fedora"
           when /ubuntu/i
             "ubuntu"
           when /solaris|sunos/i
             "stub/steelblue-s"
           when /darwin/i
             "stub/darkred-d"
           when /centos/i
             "centos"
           when /scientific/i
             "scientific"
           when /archlinux/i
             "archlinux"
           when /alt/i
             "alt"
           when /gentoo/i
             "gentoo"
           when /SLC/i
             "stub/blue-s"
           when /FreeBSD/i
             "freebsd"
           when /aix/i
             "stub/forestgreen-a"
           when /Junos/i
             "stub/darkblue-j"
           when /VRP/i
             "stub/firebrick-h"
           when /OracleLinux/i
             "stub/firebrick-o"
           when /CoreOS|ContainerLinux|Container Linux/i
             "coreos"
           when /RancherOS/i
             "rancheros"
           when /NXOS/i
             "stub/darkslateblue-n"
           when /XenServer/i
             "stub/black-x"
           when /Puppet/i
             "stub/goldenrod-p"
           when /Windows/i
             "stub/steelblue-w"
           else
             return "icons#{size}/black-\%23.png" if record.family.blank?
             record.family.downcase
           end
    return image_path("icons#{size}/#{name}.png") if opts[:path]

    image_tag("icons#{size}/#{name}.png", opts) + '&nbsp;'.html_safe
  end

  def os_name(record, opts = {})
    icon(record, opts).html_safe << record.to_label
  end

  def os_habtm_family(type, obj)
    result = type.where(:os_family => obj.family)
    result.empty? ? type : result
  end
end
