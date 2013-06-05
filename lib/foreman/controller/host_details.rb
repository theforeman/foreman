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
    render :partial => "common/os_selection/image_details", :locals => { :item => item_object }
  end

  def domain_selected
    respond_to do |format|
      format.html {assign_parameter "domain", "common/"}
      format.json do
        taxonomy_scope
        Taxonomy.as_taxonomy @organization, @location do
          if (domain = Domain.find(params[:domain_id]))
            render :json => domain.subnets
          else
            not_found
          end
        end
      end
    end
  end

  def use_image_selected
    item = item_object
    render :json => {:use_image => item.use_image, :image_file => item.image_file}
  end

  private
  def assign_parameter name, root = ""
    taxonomy_scope
    Taxonomy.as_taxonomy @organization, @location do
      if params["#{name}_id"].to_i > 0 and eval("@#{name} = #{name.classify}.find(params['#{name}_id'])")
        item = eval("@#{controller_name.singularize} || #{controller_name.classify}.new(params[:#{controller_name.singularize}])")
        render :partial => root + name, :locals => { :item => item }
      else
        head(:not_found)
      end
    end
  end

  def item_name
    controller_name.singularize
  end

  # Initiate a new object based on current context, e.g:
  # @host = Host.new params[:host]
  def item_object
    name = item_name
    eval("@#{name} = #{name.classify}.new params[:#{name}]")
  end

  def taxonomy_scope
    @organization = params[:organization_id].blank? ? nil : Organization.find(Array.wrap(params[:organization_id]))
    @location     = params[:location_id].blank? ? nil : Location.find(Array.wrap(params[:location_id]))
  end

end
