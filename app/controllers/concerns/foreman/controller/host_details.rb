# This module extract repeating methods which handle host assoications of hostgroups, os etc
# Mainly used within the host and the hostgroup controllers

module Foreman::Controller::HostDetails
  extend ActiveSupport::Concern

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
          if (domain = Domain.find_by_id(params[:domain_id]))
            render :json => domain.subnets
          elsif params[:interface]
            render :json => Subnet.authorized(:view_subnets)
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
  def assign_parameter(name, root = "")
    taxonomy_scope
    Taxonomy.as_taxonomy @organization, @location do
      if params["#{name}_id"].to_i > 0 and instance_variable_set("@#{name}",name.classify.constantize.find(params["#{name}_id"]))
        item = instance_variable_get("@#{controller_name.singularize}") || controller_name.classify.constantize.new(params[controller_name.singularize])
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
    instance_variable_set("@#{name}", name.classify.constantize.new(params[name.to_sym]))
  end

end
