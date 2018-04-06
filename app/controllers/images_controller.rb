class ImagesController < ApplicationController
  include Foreman::Controller::Parameters::Image

  before_action :find_compute_resource
  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    # Listing images in /hosts/new consumes this method as JSON
    @images = resource_base.where(:compute_resource_id => @compute_resource.id).includes(:operatingsystem)
    respond_to do |format|
      format.html { params[:partial] ? render(:partial => 'images/list') : render(:index) }
      format.json { render :json => @images.where(:operatingsystem_id => params[:operatingsystem_id], :architecture_id => params[:architecture_id]).order(:name) }
    end
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      process_success :success_redirect => compute_resource_path(@compute_resource)
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @image.update(image_params.reject { |k, v| k == :password && v.blank? })
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
    @compute_resource = ComputeResource.authorized(:view_compute_resources).find(params.delete(:compute_resource_id))
  end
end
