# This module extract repeating methods which handle host assoications of hostgroups, os etc
# Mainly used within the host and the hostgroup controllers

module Foreman::Controller::HostDetails

  def architecture_selected
    assign_parameter "architecture", "common/os_selection/"
  end

  def os_selected
    assign_parameter "operatingsystem", "common/os_selection/"
  end

  def medium_selected
    # Maybe this method can be folded into assign_parameter
    item = eval("@#{controller_name.singularize} = #{controller_name.singularize.capitalize}.new  params[:#{controller_name.singularize}]")
    render :partial => "common/os_selection/image_details", :locals => {:item => item }
  end

  def use_image_selected
    item = eval("@#{controller_name.singularize} = #{controller_name.singularize.capitalize}.new  params[:#{controller_name.singularize}]")
    render(:update) do |page|
      if item.use_image
        page["##{controller_name.singularize}_image_file"].value  = item.image_file || item.default_image_file
        page["##{controller_name.singularize}_image_file"].attr('disabled', false)
      else
        page["##{controller_name.singularize}_image_file"].value = ""
        page["##{controller_name.singularize}_image_file"].attr('disabled', true)
      end
    end
  end

  private
  def assign_parameter name, root = ""
    if params["#{name}_id"].to_i > 0 and eval("@#{name} = #{name.capitalize}.find(params['#{name}_id'])")
      item = eval("@#{controller_name.singularize} || #{controller_name.singularize.capitalize}.new(params[:#{controller_name.singularize}])")
      render :partial => root + name, :locals => {:item => item }
    else
      return head(:not_found)
    end
  end

end
