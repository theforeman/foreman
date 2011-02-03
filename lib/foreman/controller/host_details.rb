# This module extract repeating methods which handle host assoications of hostgroups, os etc
# Mainly used within the host and the hostgroup controllers

module Foreman::Controller::HostDetails

  def architecture_selected
    assign_parameter "architecture", "common/os_selection/"
  end

  def os_selected
    assign_parameter "operatingsystem", "common/os_selection/"
  end

  private
  def assign_parameter name, root = ""
    if params["#{name}_id"].to_i > 0 and eval("@#{name} = #{name.capitalize}.find(params['#{name}_id'])")
      render :partial => root + name, :locals => {:item => eval("@#{controller_name.singularize} || #{controller_name.singularize.capitalize}.new")}
    else
      return head(:not_found)
    end
  end

end
