class MediasController < ApplicationController
  def index
    @medias = Media.all(:include => [:operatingsystem])
  end

  def new
    @media = Media.new
  end

  def create
    @media = Media.new(params[:media])
    if @media.save
      flash[:notice] = "Successfully created media."
      redirect_to medias_url
    else
      render :action => 'new'
    end
  end

  def edit
    @media = Media.find(params[:id])
  end

  def update
    @media = Media.find(params[:id])
    if @media.update_attributes(params[:media])
      flash[:notice] = "Successfully updated media."
      redirect_to medias_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @media = Media.find(params[:id])
    @media.destroy
    flash[:notice] = "Successfully destroyed media."
    redirect_to medias_url
  end
end
