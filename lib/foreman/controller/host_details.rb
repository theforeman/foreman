# This module is useful for
#
# After including this module, the controller needs to implement the following function:
#
#  def get_assign_param_locals
#   {:type => "host", :item => @host}
#  end
#
# changing :type and :item where appropriate

module Foreman::Controller::HostDetails

  def architecture_selected
    assign_parameter "architecture", "common/os_selection/"
  end

  def os_selected
    assign_parameter "operatingsystem", "common/os_selection/"
  end

  def domain_selected
    assign_parameter "domain"
  end

  def assign_parameter name, root = ""
    if params["#{name}_id"].to_i > 0 and eval("@#{name} = #{name.capitalize}.find(params['#{name}_id'])")
      render :partial => root + name, :locals => assign_param_locals
    else
      return head(:not_found)
    end
  end

end
