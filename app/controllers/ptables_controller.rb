class PtablesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    @ptables = resource_base.includes(:operatingsystems).
      search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @ptable = Ptable.new
  end

  def create
    @ptable = Ptable.new(foreman_params)
    if @ptable.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @ptable.update_attributes(foreman_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @ptable.destroy
      process_success
    else
      process_error
    end
  end
end
