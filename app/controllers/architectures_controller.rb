class ArchitecturesController < ApplicationController

  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    base = resource_base.includes(:operatingsystems).search_for(params[:search], :order => params[:order])
    @architectures = base.paginate(:page => params[:page])
  end

  def new
    @architecture = Architecture.new
  end

  def create
    @architecture = Architecture.new(foreman_params)
    if @architecture.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @architecture.update_attributes(foreman_params)
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
