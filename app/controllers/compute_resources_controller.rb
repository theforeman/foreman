class ComputeResourcesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::ComputeResource

  AJAX_REQUESTS = [:template_selected, :cluster_selected, :resource_pools]
  before_action :ajax_request, :only => AJAX_REQUESTS
  before_action :find_resource, :only => [:show, :edit, :associate, :update, :destroy, :ping, :refresh_cache] + AJAX_REQUESTS

  #This can happen in development when removing a plugin
  rescue_from ActiveRecord::SubclassNotFound do |e|
    type = (e.to_s =~ /failed to locate the subclass: '((\w|::)+)'/) ? $1 : 'STI-Type'
    render :plain => (e.to_s+"<br><b>run ComputeResource.where(:type=>'#{type}').delete_all to recover.</b>").html_safe, :status=> :internal_server_error
  end

  def index
    @compute_resources = resource_base_search_and_page.live_descendants
  end

  def new
    @compute_resource = ComputeResource.new
  end

  def show
  end

  def create
    if params[:compute_resource].present? && compute_resource_params[:provider].present?
      @compute_resource = ComputeResource.new_provider compute_resource_params
      if @compute_resource.save
        process_success :success_redirect => @compute_resource
      else
        process_error
      end
    else
      @compute_resource = ComputeResource.new compute_resource_params
      @compute_resource.valid?
      process_error
    end
  end

  def edit
  end

  def associate
    count = 0
    if @compute_resource.respond_to?(:associated_host)
      @compute_resource.vms(:eager_loading => true).each do |vm|
        if Host.for_vm(@compute_resource, vm).empty?
          host = @compute_resource.associated_host(vm)
          if host.present?
            host.associate!(@compute_resource, vm)
            count += 1
          end
        end
      end
    end
    process_success(:success_msg => n_("%s VM associated to a host", "%s VMs associated to hosts", count) % count)
  end

  def update
    if @compute_resource.update_attributes(compute_resource_params)
      process_success :success_redirect => compute_resources_path
    else
      process_error
    end
  end

  def destroy
    if @compute_resource.destroy
      process_success
    else
      process_error
    end
  end

  def refresh_cache
    if @compute_resource.respond_to?(:refresh_cache) && @compute_resource.refresh_cache
      process_success(
        :success_msg => _('Successfully refreshed the cache.'),
        :success_redirect => @compute_resource
      )
    else
      process_error(
        :error_msg => _('Failed to refresh the cache.'),
        :redirect => @compute_resource
      )
    end
  end

  #ajax methods
  def provider_selected
    @compute_resource = ComputeResource.new_provider :provider => params[:provider]
    render :partial => "compute_resources/form", :locals => { :compute_resource => @compute_resource }
  end

  def ping
    respond_to do |format|
      format.json {render :json => errors_hash(@compute_resource.ping)}
    end
  end

  def test_connection
    # cr_id is posted from AJAX function. cr_id is nil if new
    if params[:cr_id].present?
      @compute_resource = ComputeResource.authorized(:edit_compute_resources).find(params[:cr_id])
      @compute_resource.attributes = compute_resource_params.reject { |k,v| k == :password && v.blank? }
    else
      @compute_resource = ComputeResource.new_provider(compute_resource_params)
    end
    @compute_resource.test_connection :force => true
    render :partial => "compute_resources/form", :locals => { :compute_resource => @compute_resource }
  end

  def template_selected
    compute = @compute_resource.template(params[:template_id])
    respond_to do |format|
      format.json { render :json => compute }
    end
  end

  def cluster_selected
    networks = @compute_resource.networks(:cluster_id => params[:cluster_id])
    respond_to do |format|
      format.json { render :json => networks }
    end
  end

  def resource_pools
    return head(:method_not_allowed) unless @compute_resource.is_a? Foreman::Model::Vmware
    pools = @compute_resource.available_resource_pools(:cluster_id => params[:cluster_id])
    respond_to do |format|
      format.json { render :json => pools }
    end
  end

  private

  def action_permission
    case params[:action]
      when 'associate'
        'edit'
      when 'ping', 'template_selected', 'cluster_selected', 'resource_pools', 'refresh_cache'
        'view'
      else
        super
    end
  end

  def two_pane?
    super && params[:action] != 'show'
  end
end
