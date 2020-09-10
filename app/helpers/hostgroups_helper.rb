module HostgroupsHelper
  include CommonParametersHelper
  include HostsAndHostgroupsHelper

  def warning_message(group)
    msg = [_("Delete %s?") % group.title]
    if group.has_children?
      msg << _("This group has nested groups!") + "\n"
      msg << _("Please delete all nested groups before deleting it.")
    end
    msg.join("\n")
  end

  def parent_hostgroups
    accessible_hostgroups = accessible_resource_records(:hostgroup, :title).to_a
    if @hostgroup.new_record?
      accessible_hostgroups
    else
      accessible_hostgroups - @hostgroup.descendants - [@hostgroup]
    end
  end
end
