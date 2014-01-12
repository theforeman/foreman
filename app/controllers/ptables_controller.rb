class PtablesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    @ptables = Ptable.
      authorized(:view_ptables).
      includes(:operatingsystems).
      search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @ptable = Ptable.new
  end

  def create
    @ptable = Ptable.new(params[:ptable])
    if @ptable.save
      process_success
    else
      process_error
    end
  end

  def edit
    @ptable = find_ptable(:edit_ptables)
  end

  def update
    @ptable = find_ptable(:edit_ptables)
    if @ptable.update_attributes(params[:ptable])
      process_success
    else
      process_error
    end
  end

  def destroy
    @ptable = find_ptable(:destroy_ptables)
    if @ptable.destroy
      process_success
    else
      process_error
    end
  end

  private
  def find_ptable(permission = :view_ptables)
    Ptable.authorized(permission).find(params[:id])
  end

end
