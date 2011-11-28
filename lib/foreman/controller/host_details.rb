# This module extract repeating methods which handle host assoications of hostgroups, os etc
# Mainly used within the host and the hostgroup controllers

module Foreman::Controller::HostDetails
  def self.included(base)
    base.class_eval do
      after_filter :disconnect_from_hypervisor, :only => :hypervisor_selected
    end
  end

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
    assign_parameter "domain", "common/"
  end

  def use_image_selected
    item = item_object
    iname = item_name
    render(:update) do |page|
      if item.use_image
        page["##{iname}_image_file"].value = item.image_file || item.default_image_file
        page["##{iname}_image_file"].attr('disabled', false)
      else
        page["##{iname}_image_file"].value = ""
        page["##{iname}_image_file"].attr('disabled', true)
      end
    end
  end

  def hypervisor_selected
    hypervisor_id = params["hypervisor_id".to_sym].to_i

    # bare metal selected
    hypervisor_defaults and return if hypervisor_id == 0

    item = item_object
    if ((item.hypervisor_id = hypervisor_id) > 0) and (@hypervisor = Hypervisor.find(item.hypervisor_id))
      begin
        @hypervisor.connect
      rescue => e
        # we reset to default
        item.hypervisor_id = nil
        logger.warn e.to_s
        hypervisor_defaults(e.to_s) and return
      end

      @guest = Virt::Guest.new({ :name => (item.try(:name) || "new-#{Time.now.to_i}") })

      render :update do |page|
        controller.send(:update_hypervisor_details, item, page)
      end
    else
      return head(:not_found)
    end
  end

  private
  def assign_parameter name, root = ""
    if params["#{name}_id"].to_i > 0 and eval("@#{name} = #{name.capitalize}.find(params['#{name}_id'])")
      item = eval("@#{controller_name.singularize} || #{controller_name.singularize.capitalize}.new(params[:#{controller_name.singularize}])")
      render :partial => root + name, :locals => { :item => item }
    else
      return head(:not_found)
    end
  end

  def item_name
    controller_name.singularize
  end

  # Initiate a new object based on current context, e.g:
  # @host = Host.new params[:host]
  def item_object
    name = item_name
    eval("@#{name} = #{name.capitalize}.new params[:#{name}]")
  end

  def update_hypervisor_details item, page
    page['#virtual_machine'].html(render(:partial => "common/hypervisor", :locals => { :item => item }))
    page << "if ($('#host_mac')) $('#host_mac').parentsUntil('.clearfix').parent().remove()"
  end

  def disconnect_from_hypervisor
    @hypervisor.disconnect if @hypervisor
  end

  def hypervisor_defaults msg = nil
    @hypervisor = nil
    render :update do |page|
      item = controller.send(:item_object)
      page.alert(msg) if msg
      page.replace_html :virtual_machine, :partial => "common/hypervisor", :locals => { :item => item }
      # you can only select bare metal after you successfully selected a hypervisor before
      page << "if ($('#host_mac').length == 0) {"
      page.replace_html :mac_address, :partial => "hosts/mac", :locals => {:item => item } if controller_name == "hosts"
      page[:host_hypervisor_id].value = ""
      page << " }"
    end
  end

end
