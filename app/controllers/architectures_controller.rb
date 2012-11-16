class ArchitecturesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => %w{show edit update destroy}

  def index
    values = Architecture.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html { @architectures = values.paginate(:page => params[:page]) }
      format.json { render :json => values.as_json }
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
