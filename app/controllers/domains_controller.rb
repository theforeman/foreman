class DomainsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    @domains      = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @domain = Domain.new
  end

  def create
    @domain = Domain.new(foreman_params)
    if @domain.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @domain.update_attributes(foreman_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @domain.destroy
      process_success
    else
      process_error
    end
  end
end
