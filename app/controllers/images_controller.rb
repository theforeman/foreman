class ImagesController < ApplicationController
  before_filter :find_compute_resource
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    # Listing images in /hosts/new consumes this method as JSON
    values = resource_base.where(:compute_resource_id => @compute_resource.id).search_for(params[:search], :order => params[:order]).includes(:operatingsystem)
    respond_to do |format|
      format.html { @images = values.paginate :page => params[:page] }
      format.json { render :json => values }
    end
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(safe_params)
    if @image.save
      process_success :success_redirect => compute_resource_path(@compute_resource)
    else
      process_error
    end
  end

  def edit
  end

  def update
    safe_params.except!(:password) if safe_params[:password].blank?
    if @image.update_attributes(safe_params)
      process_success :success_redirect => compute_resource_path(@compute_resource)
    else
      process_error
    end
  end

  def destroy
    if @image.destroy
      process_success :success_redirect => compute_resource_path(@compute_resource)
    else
      process_error
    end
  end

  private

  def find_compute_resource
    @compute_resource = ComputeResource.authorized(:view_compute_resources).find(params[:compute_resource_id])
  end
end
