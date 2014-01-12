class ArchitecturesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => %w{edit update destroy}

  def index
    base = Architecture.authorized(:view_architectures)
    base = base.includes(:operatingsystems).search_for(params[:search], :order => params[:order])
    @architectures = base.paginate(:page => params[:page])
  end

  def new
    @architecture = Architecture.new
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
