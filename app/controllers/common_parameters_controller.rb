class CommonParametersController < ApplicationController
  def index
    @search            = CommonParameter.search(params[:search])
    @common_parameters = @search.paginate(:page => params[:page])
    respond_to do |format|
      format.html
      format.json { render :json => @common_parameters}
    end
  end

  def new
    @common_parameter = CommonParameter.new
  end

  def create
    @common_parameter = CommonParameter.new(params[:common_parameter])
    if @common_parameter.save
      process_success
    else
      process_error
    end
  end

  def edit
    @common_parameter = CommonParameter.find(params[:id])
  end

  def update
    @common_parameter = CommonParameter.find(params[:id])
    if @common_parameter.update_attributes(params[:common_parameter])
      process_success
    else
      process_error
    end
  end

  def destroy
    @common_parameter = CommonParameter.find(params[:id])
    if @common_parameter.destroy
      process_success
    else
      process_error
    end
  end
end
