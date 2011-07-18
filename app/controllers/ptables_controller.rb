class PtablesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_ptable, :only => %w{show edit update destroy}

  def index
    values = Ptable.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html { @ptables = values.paginate :page => params[:page], :include => [:operatingsystems] }
      format.json { render :json => values }
    end
  end

  def show
    respond_to do |format|
      format.json { render :json => @ptable }
    end
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
  end

  def update
    if @ptable.update_attributes(params[:ptable])
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

  private
  def find_ptable
    @ptable = Ptable.find(params[:id])
  end

end
