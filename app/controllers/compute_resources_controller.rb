class ComputeResourcesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  AJAX_REQUESTS = %w{hardware_profile_selected cluster_selected}
  before_filter :ajax_request, :only => AJAX_REQUESTS
  before_filter :find_by_id, :only => [:show, :edit, :update, :destroy] + AJAX_REQUESTS

  def index
    begin
      values = ComputeResource.my_compute_resources.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = ComputeResource.my_compute_resources.search_for ""
    end

    respond_to do |format|
      format.html { @compute_resources = values.paginate :page => params[:page] }
      format.json { render :json => values }
    end
  end

  def new
    @compute_resource = ComputeResource.new
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :json => @compute_resource }
    end
  end

  def create
    if params[:compute_resource].present? && params[:compute_resource][:provider].present?
      @compute_resource = ComputeResource.new_provider params[:compute_resource]
      if @compute_resource.save
        # Add the new compute resource to the user's filters
        @compute_resource.users << User.current
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

  def update
    if @compute_resource.update_attributes(params[:compute_resource])
      process_success
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

  def test_connection
    @compute_resource ||= ComputeResource.new_provider(params[:compute_resource])
    @compute_resource.test_connection
    render :partial => "compute_resources/form", :locals => { :compute_resource => @compute_resource }
  end

  def hardware_profile_selected
    compute = @compute_resource.hardware_profile(params[:hwp_id])
    compute.interfaces
    compute.volumes
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

  def find_by_id
    @compute_resource = ComputeResource.find(params[:id])
    not_found and return unless @compute_resource
    deny_access and return unless ComputeResource.my_compute_resources.include?(@compute_resource)
  end
end
