module HostgroupsHelper
  include CommonParametersHelper
  include HostsAndHostgroupsHelper

  def warning_message group
    msg = [_("Are you sure?")]
    if group.has_children?
      msg << _("This group has nested groups!") + "\n"
      msg << _("Deleting this group will unlink its nested groups and any associated puppet classes and / or parameters")
    end
    msg.join("\n")
  end

end
