class EnvironmentsController < ApplicationController
  def index
    @search       = Environment.search(params[:search])
    @environments = @search.paginate :page => params[:page]
  end

  def show
    @environment = Environment.find(params[:id])
  end

  def new
    @environment = Environment.new
  end

  def create
    @environment = Environment.new(params[:environment])
    if @environment.save
      flash[:foreman_notice] = "Successfully created environment."
      redirect_to environments_path
    else
      render :action => 'new'
    end
  end

  def edit
    @environment = Environment.find(params[:id])
  end

  def update
    @environment = Environment.find(params[:id])
    if @environment.update_attributes(params[:environment])
      flash[:foreman_notice] = "Successfully updated environment."
      redirect_to environments_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @environment = Environment.find(params[:id])
    if @environment.destroy
      flash[:foreman_notice] = "Successfully destroyed '#{@environment.name}''"
    else
      flash[:foreman_error]  = @environment.errors.full_messages.join("<br/>")
    end
    redirect_to environments_url
  end

end
