class ComputeResourcesVmsController < ApplicationController
  before_filter :find_compute_resource
  before_filter :find_vm, :only => [:show, :power, :pause, :console, :associate]

  def index
    @vms = @compute_resource.vms.all(params[:filters] || {})
    respond_to do |format|
      format.html
      format.json { render :json => @vms }
    end
  rescue => e
    render :partial => 'compute_resources_vms/error', :locals => { :errors => e.message }
  end

  def new
    @vm = @compute_resource.new_vm
  end

  def create
    if @compute_resource.create_vm params[:vm]
      process_success :success_redirect => compute_resource_vms_path(@compute_resource)
    else
      process_error :redirect => new_compute_resource_vm_path(@compute_resource), :object => @compute_resource
    end
  end

  def associate
    if Host.where(:uuid => @vm.identity).any?
      process_error(:error_msg => _("VM already associated with a host"), :redirect => compute_resource_vm_path(:compute_resource_id => params[:compute_resource_id], :id => @vm.identity))
    else
      host = @compute_resource.associated_host(@vm) if @compute_resource.respond_to?(:associated_host)
      if host.present?
        host.uuid = @vm.identity
        host.compute_resource_id = @compute_resource.id
        host.save!(:validate => false) # don't want to trigger callbacks
        process_success(:success_msg => _("VM associated to host #{host.name}"), :success_redirect => host_path(host))
      else
        process_error(:error_msg => _("No host found to associate this VM with"), :redirect => compute_resource_vm_path(:compute_resource_id => params[:compute_resource_id], :id => @vm.identity))
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :json => @vm }
    end
  end

  def power
    run_vm_action(@vm.ready? ? :stop : :start)
  end

  def pause
    run_vm_action(@vm.ready? ? :pause : :start)
  end

  def destroy
    if @compute_resource.destroy_vm params[:id]
      process_success({ :success_redirect => compute_resource_vms_path(@compute_resource) })
    else
      process_error({ :redirect => compute_resource_vms_path(@compute_resource) })
    end
  end

  def console
    @console = @compute_resource.console @vm.identity
    render case @console[:type]
             when 'spice'
               "hosts/console/spice"
             when 'vnc'
               "hosts/console/vnc"
             else
               "hosts/console/log"
    end
  rescue => e
    process_error :redirect => compute_resource_vm_path(@compute_resource, @vm.identity), :error_msg => (_("Failed to set console: %s") % e), :object => @vm
  end

  private

  def find_compute_resource
    @compute_resource = ComputeResource.find(params[:compute_resource_id])
    @compute_resource = ComputeResource.my_compute_resources.find(params[:compute_resource_id]) rescue deny_access
  end

  def find_vm
    @vm = @compute_resource.find_vm_by_uuid params[:id]
  end

  def run_vm_action(action)
    if (@vm.send(action) rescue false)
      @vm.reload
      notice _("%{vm} is now %{vm_state}") % {:vm => @vm, :vm_state => @vm.state.capitalize}
      redirect_to compute_resource_vm_path(:compute_resource_id => params[:compute_resource_id], :id => @vm.identity)
    else
      error _("failed to %{action} %{vm}") % {:action => _(action), :vm => @vm}
      redirect_to :back
    end
  end

end
