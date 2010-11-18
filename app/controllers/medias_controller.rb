class MediasController < ApplicationController
  before_filter :find_media, :only => %w{show edit update destroy}

  def index
    respond_to do |format|
      format.html do
        @search = Media.search params[:search]
        @medias = @search.paginate(:page => params[:page], :include => [:operatingsystems])
      end
      format.json { render :json => Media.all.as_json }
    end
  end

  def show
    respond_to do |format|
      format.json { render :json => @media.as_json({:only => [:name, :id, :path]}) }
    end
  end

  def new
    @media = Media.new
  end

  def create
    @media = Media.new(params[:media])
    if @media.save
      notice "Successfully created media."
      redirect_to medias_url
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @media.update_attributes(params[:media])
      notice "Successfully updated media."
      redirect_to medias_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @media.destroy
    notice "Successfully destroyed media."
    redirect_to medias_url
  end

  private
  def find_media
    @media = Media.find(params[:id])
  end

end
