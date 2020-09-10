# This module extract repeating methods which handle host assoications of hostgroups, os etc
# Mainly used within the host and the hostgroup controllers

module Foreman::Controller::HostDetails
  extend ActiveSupport::Concern

  def architecture_selected
    assign_parameter "architecture", "common/os_selection/"
  end

  def os_selected
    assign_parameter "operatingsystem", "common/os_selection/" do |item|
      item.suggest_default_pxe_loader
    end
  end

  def medium_selected
    # Maybe this method can be folded into assign_parameter
    render :partial => "common/os_selection/image_details", :locals => { :item => item_object }
  end

  def domain_selected
    respond_to do |format|
      format.html { assign_parameter "domain", "common/" }
      format.json do
        taxonomy_scope
        Taxonomy.as_taxonomy @organization, @location do
          if (domain = Domain.find_by_id(params[:domain_id]))
            render :json => domain.subnets.as_json(:include => :unused_ip)
          elsif params[:interface]
            render :json => Subnet.authorized(:view_subnets).as_json(:include => :unused_ip)
          else
            render :json => {}
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
      item = instance_variable_get("@#{controller_name.singularize}") || controller_name.classify.constantize.new(item_params)
      instance_variable_set("@#{name}", item.send(name.to_sym))
      yield item if block_given?
      render :partial => root + name, :locals => { :item => item }
    end
  end

  def item_params
    send("#{item_name}_params".to_sym)
  end

  def item_name
    controller_name.singularize
  end

  # Initiate a new object based on current context, e.g:
  # @host = Host.new params[:host]
  def item_object
    name = item_name
    instance_variable_set("@#{name}", name.classify.constantize.new(public_send("#{name}_params".to_sym)))
  end
end
