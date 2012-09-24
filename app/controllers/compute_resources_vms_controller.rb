class ComputeResourcesVmsController < ApplicationController
  before_filter :find_compute_resource
  before_filter :find_vm, :only => [:show, :power, :pause, :console]

  def index
    @vms = @compute_resource.vms.all.to_a.paginate :page => params[:page]
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
    (power_openstack and return) if @vm.class == Fog::Compute::OpenStack::Server

    action = @vm.ready? ? :stop : :start

    if (@vm.send(action) rescue false)
      state = @vm.ready? ? "running" : "stopped"
      notice "#{@vm.name} is now #{state}"
      redirect_to compute_resource_vms_path(params[:compute_resource_id])
    else
      error "failed to #{action} #{@vm.name}"
      redirect_to :back
    end
  end
 
  def power_openstack
    action = @vm.state == 'ACTIVE' ? :suspend_server : :resume_server 

    if (@vm.connection.send(action, @vm.id) rescue false)
      state = action == :suspend_server ? 'stopped' : 'running'
      notice "#{@vm.name} is now #{state}"
      redirect_to compute_resource_vms_path(params[:compute_resource_id])
    else
      error "failed to #{action} #{@vm.name}"
      redirect_to :back
    end
  end

  def pause
    action = @vm.state == 'ACTIVE' ? :pause_server : :unpause_server 

    if (@vm.connection.send(action, @vm.id) rescue false)
      state = action == :pause_server ? 'paused' : 'running'
      notice "#{@vm.name} is now #{state}"
      redirect_to compute_resource_vms_path(params[:compute_resource_id])
    else
      error "failed to #{action} #{@vm.name}"
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
    render "hosts/console"
  rescue => e
    process_error :redirect => compute_resource_vm_path(@compute_resource, @vm.identity), :error_msg => "Failed to set console: #{e}", :object => @vm
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
