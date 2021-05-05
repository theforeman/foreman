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
    name = case record.name.downcase
           when /fedora/
             "fedora"
           when /ubuntu/
             "ubuntu"
           when /solaris|sunos/
             "stub/steelblue-s"
           when /darwin/
             "stub/darkred-d"
           when /centos/
             "centos"
           when /rocky/
             "rocky"
           when /scientific/
             "scientific"
           when /archlinux/
             "archlinux"
           when /^alt/
             "alt"
           when /gentoo/
             "gentoo"
           when /slc/
             "stub/blue-s"
           when /freebsd/
             "freebsd"
           when /aix/
             "stub/forestgreen-a"
           when /junos/
             "stub/darkblue-j"
           when /vrp/
             "stub/firebrick-h"
           when /oraclelinux/
             "stub/firebrick-o"
           when /coreos|containerlinux|container linux/
             "coreos"
           when /flatcar/
             "stub/darkblue-f"
           when /rancheros/
             "rancheros"
           when /nxos/
             "stub/darkslateblue-n"
           when /xenserver/
             "stub/black-x"
           when /puppet/
             "stub/goldenrod-p"
           when /windows/
             "stub/steelblue-w"
           when /OpenWrt/i
             "openwrt"
           when /Raspbian/i
             "raspbian"
           when /almalinux/i
             "almalinux"
           else
             if record.family.blank?
               'stub/black-x'
             else
               record.family.downcase
             end
           end
    return image_path("icons#{size}/#{name}.png") if opts[:path]

    os_image_tag size, name, opts
  end

  def os_image_tag(size, name, opts)
    image_tag("icons#{size}/#{name}.png", opts) + '&nbsp;'.html_safe
  end

  def os_name(record, opts = {})
    icon(record, opts).html_safe << record.to_label
  end

  def os_habtm_family(type, obj)
    result = type.where(:os_family => obj.family)
    result.empty? ? type : result
  end

  def os_default_templates_for_form(os)
    if os.os_default_templates.any?(&:new_record?)
      os.os_default_templates.sort_by { |o| o.template_kind.name.downcase }
    else
      os.os_default_templates.joins(:template_kind).order(TemplateKind.arel_table[:name].lower)
    end
  end
end
