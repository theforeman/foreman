class ImagesController < ApplicationController
  before_action :find_compute_resource
  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    # Listing images in /hosts/new consumes this method as JSON
    @images = resource_base.where(:compute_resource_id => @compute_resource.id).includes(:operatingsystem)
    respond_to do |format|
      format.html { render :partial => 'images/list' }
      format.json { render :json => @images.where(:operatingsystem_id => params[:operatingsystem_id], :architecture_id => params[:architecture_id]) }
    end
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(params[:image])
    if @image.save
      process_success :success_redirect => compute_resource_path(@compute_resource)
    else
      process_error
    end
  end

  def edit
  end

  def update
    params[:image].except!(:password) if params[:image][:password].blank?
    if @image.update_attributes(params[:image])
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
