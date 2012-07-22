class ImagesController < ApplicationController
  before_filter :find_compute_resource
  before_filter :find_by_name, :except => [:index, :new, :create]

  def index
    values = @compute_resource.images.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html { @images = values.paginate :page => params[:page] }
      format.json { render :json => values }
    end
  end

  def new
    @image = Image.new
  end

  def show
    respond_to do |format|
      format.json { render :json => @image }
    end
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
    @compute_resource = ComputeResource.find(params[:compute_resource_id])
  end

end
