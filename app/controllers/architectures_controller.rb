class ArchitecturesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => %w{show edit update destroy}

  def index
    @architectures = Architecture.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page], :include => :operatingsystems)
  end

  def new
    @architecture = Architecture.new
  end

  def show
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
