class ArchitecturesController < ApplicationController
  before_filter :find_arch, :only => %w{show edit update destroy}

  def index
    respond_to do |format|
      format.html do
        @search        = Architecture.search(params[:search])
        @architectures = @search.paginate(:page => params[:page], :include => :operatingsystems)
      end
      format.json { render :json => Architecture.all }
    end
  end

  def new
    @architecture = Architecture.new
  end

  def show
    respond_to do |format|
      format.json { render :json => @architecture }
    end
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
  end

  def update
    if @architecture.update_attributes(params[:architecture])
      flash[:notice] = "Successfully updated architecture."
      redirect_to architectures_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @architecture.destroy
    flash[:notice] = "Successfully destroyed architecture."
    redirect_to architectures_url
  end

  private
  def find_arch
    @architecture = Architecture.find_by_name(params[:id])
  end
end
