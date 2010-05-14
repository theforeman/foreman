class CommonParametersController < ApplicationController
  def index
    @search            = CommonParameter.search(params[:search])
    @common_parameters = @search.paginate(:page => params[:page])
  end

  def new
    @common_parameter = CommonParameter.new
  end

  def create
    @common_parameter = CommonParameter.new(params[:common_parameter])
    if @common_parameter.save
      flash[:foreman_notice] = "Successfully created common parameter."
      redirect_to common_parameters_url
    else
      render :action => 'new'
    end
  end

  def edit
    @common_parameter = CommonParameter.find(params[:id])
  end

  def update
    @common_parameter = CommonParameter.find(params[:id])
    if @common_parameter.update_attributes(params[:common_parameter])
      flash[:foreman_notice] = "Successfully updated common parameter."
      redirect_to common_parameters_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @common_parameter = CommonParameter.find(params[:id])
    @common_parameter.destroy
    flash[:foreman_notice] = "Successfully destroyed common parameter."
    redirect_to common_parameters_url
  end
end
