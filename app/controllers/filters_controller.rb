class FiltersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_role
  before_filter :setup_search_options, :only => :index

  def index
    @filters = @base.includes(:role, :permissions).search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @filter = @base.build
  end

  def create
    @filter = Filter.new(params[:filter])
    if @filter.save
      process_success :success_redirect => filters_path(:role_id => @role)
    else
      process_error
    end
  end

  def edit
    @filter = @base.includes(:permissions).find(params[:id])
  end

  def update
    @filter = @base.find(params[:id])
    if @filter.update_attributes(params[:filter])
      process_success :success_redirect => filters_path(:role_id => @role)
    else
      process_error
    end
  end

  def destroy
    @filter = @base.find(params[:id])
    if @filter.destroy
      process_success :success_redirect => filters_path(:role_id => @role)
    else
      process_error
    end
  end

  protected

  def find_role
    @role = Role.find_by_id(role_id)
    @base = @role.present? ? @role.filters : Filter.scoped
  end

  def role_id
    params[:role_id]
  end
end
