class MediaController < ApplicationController
  before_filter :find_medium, :only => %w{show edit update destroy}

  def index
    respond_to do |format|
      format.html do
        @search = Medium.search params[:search]
        @media = @search.paginate(:page => params[:page], :include => [:operatingsystems])
      end
      format.json { render :json => Medium.all.as_json }
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
      notice "Successfully created medium."
      redirect_to media_url
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @medium.update_attributes(params[:medium])
      notice "Successfully updated medium."
      redirect_to media_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @medium.destroy
    notice "Successfully destroyed medium."
    redirect_to media_url
  end

  private
  def find_medium
    @medium = Medium.find(params[:id])
  end

end
