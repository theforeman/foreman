class ArchitecturesController < ApplicationController
  def index
    @search        = Architecture.search(params[:search])
    @architectures = @search.paginate(:page => params[:page], :include => :operatingsystems)
  end

  def new
    @architecture = Architecture.new
  end

  def create
    @architecture = Architecture.new(params[:architecture])
    if @architecture.save
      flash[:notice] = "Successfully created architecture."
      redirect_to architectures_url
    else
      render :action => 'new'
    end
  end

  def edit
    @architecture = Architecture.find(params[:id], :include => :operatingsystems)
  end

  def update
    @architecture = Architecture.find(params[:id])
    if @architecture.update_attributes(params[:architecture])
      flash[:notice] = "Successfully updated architecture."
      redirect_to architectures_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @architecture = Architecture.find(params[:id])
    @architecture.destroy
    flash[:notice] = "Successfully destroyed architecture."
    redirect_to architectures_url
  end
end
