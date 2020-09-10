class ComputeResourcesVmsController < ApplicationController
  include Foreman::Controller::ComputeResourcesCommon
  include ::Foreman::Controller::ActionPermissionDsl
  include ::Foreman::Controller::HostFormCommon
  include Foreman::Controller::ConsoleCommon

  before_action :find_compute_resource
  before_action :find_vm, :only => [:import, :associate, :show, :console, :pause, :power]

  helper :hosts

  def controller_permission
    return :compute_resources if params[:action] == 'associate'
    super
  end

  def index
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
    compute_resource_error("VMs", e)
  end

  def new
    @vm = @compute_resource.new_vm
  end

  def create
    params[:vm].permit!
    if (vm = @compute_resource.create_vm params[:vm])
      @compute_resource.start_vm(vm.identity) if params[:vm][:start] == '1'
      process_success :success_redirect => compute_resource_vms_path(@compute_resource)
    else
      process_error :redirect => new_compute_resource_vm_path(@compute_resource), :object => @compute_resource
    end
  end

  def associate
    if Host.for_vm(@compute_resource, @vm).any?
      process_error(:error_msg => _("VM already associated with a host"), :redirect => compute_resource_vm_path(:compute_resource_id => params[:compute_resource_id], :id => @vm.identity))
      return
    end
    host = @compute_resource.associated_host(@vm) if @compute_resource.respond_to?(:associated_host)
    if host.present?
      host.associate!(@compute_resource, @vm)
      process_success(:success_msg => _("VM associated to host %s") % host.name, :success_redirect => host_path(host))
    else
      process_error(:error_msg => _("No host found to associate this VM with"), :redirect => compute_resource_vm_path(:compute_resource_id => params[:compute_resource_id], :id => @vm.identity))
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
      process_success({ :success_redirect => compute_resource_vms_path(@compute_resource), :success_msg => _('The virtual machine is being deleted.') })
    else
      process_error({ :redirect => compute_resource_vms_path(@compute_resource) })
    end
  end

  def console
    @console = @compute_resource.console @vm.identity
    super
  rescue => e
    process_error :redirect => compute_resource_vm_path(@compute_resource, @vm.identity), :error_msg => (_("Failed to set console: %s") % e), :object => @vm
  end

  def import
    @host = ComputeResourceHostImporter.new(
      :compute_resource => @compute_resource,
      :vm => @vm,
      :managed => (params[:type] != 'unmanaged')
    ).host
    load_vars_for_ajax
  end

  private

  define_action_permission 'console', :console
  define_action_permission ['pause', 'power'], :power
  define_action_permission 'import', :view
  define_action_permission 'associate', :edit # edit_compute_resources

  def find_compute_resource
    @compute_resource = ComputeResource.authorized(current_permission).find(params[:compute_resource_id])
  end

  def find_vm
    @vm = @compute_resource.find_vm_by_uuid(params[:id])
  end

  def run_vm_action(action)
    if @vm.send(action)
      @vm.reload
      success _("%{vm} is now %{vm_state}") % {:vm => @vm, :vm_state => @vm.state.capitalize}
    else
      error _("failed to %{action} %{vm}") % {:action => _(action), :vm => @vm}
    end
    redirect_back(:fallback_location => compute_resource_vm_path(:compute_resource_id => params[:compute_resource_id], :id => @vm.identity))
  # This should only rescue Fog::Errors, but Fog returns all kinds of errors...
  rescue => e
    error _("Error - %{message}") % { :message => _(e.message) }
    redirect_back(:fallback_location => compute_resource_vm_path(:compute_resource_id => params[:compute_resource_id], :id => @vm.identity))
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
