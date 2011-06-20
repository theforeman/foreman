module HostgroupsHelper
  include CommonParametersHelper
  include HostsAndHostgroupsHelper

  def warning_message group
    msg = ["Are you sure?"]
    if group.has_children?
      msg << "This group has nested groups!\n"
      msg << "Deleting this group will unlink its nested groups and any associated puppet classes and / or parameters"
    end
    msg.join("\n")
  end

end
