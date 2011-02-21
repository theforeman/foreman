class ArchitecturesController < ApplicationController
  before_filter :find_by_name, :only => %w{show edit update destroy}

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
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @architecture.update_attributes(params[:architecture])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @architecture.destroy
      process_success
    else
      process_error
    end
  end

end
