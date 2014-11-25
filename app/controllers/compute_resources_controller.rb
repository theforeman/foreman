class ComputeResourcesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  AJAX_REQUESTS = [:template_selected, :cluster_selected]
  before_filter :ajax_request, :only => AJAX_REQUESTS
  before_filter :find_resource, :only => [:show, :edit, :associate, :update, :destroy, :ping] + AJAX_REQUESTS

  #This can happen in development when removing a plugin
  rescue_from ActiveRecord::SubclassNotFound do |e|
    type = (e.to_s =~ /failed to locate the subclass: '((\w|::)+)'/) ? $1 : 'STI-Type'
    render :text => (e.to_s+"<br><b>run ComputeResource.delete_all(:type=>'#{type}') to recover.</b>").html_safe, :status=> 500
  end

  def index
    @compute_resources = resource_base.live_descendants.search_for(params[:search], :order => params[:order]).paginate :page => params[:page]
  end

  def new
    @compute_resource = ComputeResource.new
  end

  def show
  end

  def create
    if params[:compute_resource].present? && params[:compute_resource][:provider].present?
      @compute_resource = ComputeResource.new_provider(foreman_params)
      if @compute_resource.save
        process_success :success_redirect => @compute_resource
      else
        process_error
      end
    else
      @compute_resource = ComputeResource.new params[:compute_resource]
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
    params[:compute_resource].except!(:password) if params[:compute_resource][:password].blank?
    if @compute_resource.update_attributes(foreman_params)
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
    Rails.logger.info "CR_ID IS #{params[:cr_id]}"
    if params[:cr_id].present? && params[:cr_id] != 'null'
      @compute_resource = ComputeResource.authorized(:edit_compute_resources).find(params[:cr_id])
      params[:compute_resource].delete(:password) if params[:compute_resource][:password].blank?
      @compute_resource.attributes = params[:compute_resource]
    else
      @compute_resource = ComputeResource.new_provider(params[:compute_resource])
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

  private

  def action_permission
    case params[:action]
      when 'associate'
        'edit'
      when 'ping', 'template_selected', 'cluster_selected'
        'view'
      else
        super
    end
  end
end
