class ComputeResourcesVmsController < ApplicationController
  def index
    @compute_resource = find_compute_resource(:view_compute_resources_vms)
    load_vms
    @authorizer = Authorizer.new(User.current, :collection => [@compute_resource])
    respond_to do |format|
      format.html
      format.json do
        if @compute_resource.supports_vms_pagination?
          render :partial => "compute_resources_vms/index/#{@compute_resource.provider.downcase}.json"
        else
          render :json => _('JSON VM listing is not supported for this compute resource.'),
                 :status => :not_implemented
        end
      end
    end
  rescue => e
    Foreman::Logging.exception("Error has occurred while listing VMs on #{@compute_resource}", e)
    render :partial => 'compute_resources_vms/error', :locals => { :errors => e.message }
  end

  def new
    @compute_resource = find_compute_resource
    @vm = @compute_resource.new_vm
  end

  def create
    @compute_resource = find_compute_resource

    if (vm = @compute_resource.create_vm params[:vm])
      @compute_resource.start_vm(vm.identity) if params[:vm][:start]=='1'
      process_success :success_redirect => compute_resource_vms_path(@compute_resource)
    else
      process_error :redirect => new_compute_resource_vm_path(@compute_resource), :object => @compute_resource
    end
  end

  def associate
    @compute_resource = find_compute_resource(:edit_compute_resources)
    @vm = find_vm
    if Host.for_vm(@compute_resource, @vm).any?
      process_error(:error_msg => _("VM already associated with a host"), :redirect => compute_resource_vm_path(:compute_resource_id => params[:compute_resource_id], :id => @vm.identity))
    else
      host = @compute_resource.associated_host(@vm) if @compute_resource.respond_to?(:associated_host)
      if host.present?
        host.associate!(@compute_resource, @vm)
        process_success(:success_msg => _("VM associated to host %s") % host.name, :success_redirect => host_path(host))
      else
        process_error(:error_msg => _("No host found to associate this VM with"), :redirect => compute_resource_vm_path(:compute_resource_id => params[:compute_resource_id], :id => @vm.identity))
      end
    end
  end

  def show
    @compute_resource = find_compute_resource(:view_compute_resources_vms)
    @vm = find_vm
    respond_to do |format|
      format.html
      format.json { render :json => @vm }
    end
  end

  def power
    @compute_resource = find_compute_resource(:power_compute_resources_vms)
    @vm = find_vm
    run_vm_action(@vm.ready? ? :stop : :start)
  end

  def pause
    @compute_resource = find_compute_resource(:power_compute_resources_vms)
    @vm = find_vm
    run_vm_action(@vm.ready? ? :pause : :start)
  end

  def destroy
    @compute_resource = find_compute_resource(:destroy_compute_resources_vms)
    if @compute_resource.destroy_vm params[:id]
      process_success({ :success_redirect => compute_resource_vms_path(@compute_resource), :success_msg => _('The virtual machine is being deleted.') })
    else
      process_error({ :redirect => compute_resource_vms_path(@compute_resource) })
    end
  end

  def console
    @compute_resource = find_compute_resource(:console_compute_resources_vms)
    @vm = find_vm
    @console = @compute_resource.console @vm.identity
    @encrypt = Setting[:websockets_encrypt]
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

  def find_compute_resource(permission = :view_compute_resources)
    ComputeResource.authorized(permission).find(params[:compute_resource_id])
  end

  def find_vm
    @compute_resource.find_vm_by_uuid params[:id]
  end

  def run_vm_action(action)
    if @vm.send(action)
      @vm.reload
      notice _("%{vm} is now %{vm_state}") % {:vm => @vm, :vm_state => @vm.state.capitalize}
      redirect_to compute_resource_vm_path(:compute_resource_id => params[:compute_resource_id], :id => @vm.identity)
    else
      error _("failed to %{action} %{vm}") % {:action => _(action), :vm => @vm}
      redirect_to :back
    end
  # This should only rescue Fog::Errors, but Fog returns all kinds of errors...
  rescue => e
    error _("Error - %{message}") % { :message => _(e.message) }
    redirect_to :back
  end

  def load_vms
    if @compute_resource.supports_vms_pagination?
      return if request.format.html? # html loads only thead, no nead to load all vms
      opts = @compute_resource.parse_vms_list_params(params)
    else
      opts = {}
    end
    @vms = @compute_resource.vms.all(opts)
  end
end
