class ComputeResourcesVmsController < ApplicationController
  before_filter :find_compute_resource
  before_filter :find_vm, :only => [:show, :power, :console]

  def index
    @vms = @compute_resource.vms.all(params[:filters] || {})
    respond_to do |format|
      format.html
      format.json { render :json => @vms }
    end
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

  def show
    respond_to do |format|
      format.html
      format.json { render :json => @vm }
    end
  end

  def power
    action = @vm.ready? ? :stop : :start

    if (@vm.send(action) rescue false)
      @vm.reload
      notice _("%{vm} is now %{vm_state}") % {:vm => @vm, :vm_state => @vm.state.capitalize}
      redirect_to compute_resource_vm_path(:compute_resource_id => params[:compute_resource_id], :id => @vm.identity)
    else
      error _("failed to %{action} %{vm}") % {:action => action, :vm => @vm}
      redirect_to :back
    end
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

end
