class MediaController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_medium, :only => %w{show edit update destroy}

  def index
    values = Medium.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html { @media = values.paginate(:page => params[:page], :include => [:operatingsystems]) }
      format.json { render :json => values }
    end
  end

  def show
    respond_to do |format|
      format.json { render :json => @medium.as_json({:only => [:name, :id, :path]}) }
    end
  end

  def new
    @medium = Medium.new
  end

  def create
    @medium = Medium.new(params[:medium])
    if @medium.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @medium.update_attributes(params[:medium])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @medium.destroy
      process_success
    else
      process_error
    end
  end

  private
  def find_medium
    @medium = Medium.find(params[:id])
  end

end
