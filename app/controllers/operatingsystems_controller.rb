class OperatingsystemsController < ApplicationController
  before_filter :find_os, :only => %w{show edit update destroy bootfiles}

  def index
    respond_to do |format|
      format.html do
        @search           = Operatingsystem.search(params[:search])
        @operatingsystems = @search.all.paginate(:page => params[:page], :include => [:architectures], :order => :name)
      end
      format.json { render :json => Operatingsystem.all(:include => [:medias, :architectures, :ptables]) }
    end

  end

  def new
    @operatingsystem = Operatingsystem.new
  end

  def show
    respond_to do |format|
      format.json { render :json => @operatingsystem }
    end
  end

  def create
    @operatingsystem = Operatingsystem.new(params[:operatingsystem])
    if @operatingsystem.save
      notice "Successfully created operatingsystem."
      redirect_to operatingsystems_url
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @operatingsystem.update_attributes(params[:operatingsystem])
      notice "Successfully updated operatingsystem."
      redirect_to operatingsystems_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @operatingsystem.destroy
      notice "Successfully destroyed operatingsystem."
    else
      error @operatingsystem.errors.full_messages.join("<br/>")
    end
    redirect_to operatingsystems_url
  end

  def bootfiles
    media = Media.find_by_name(params[:media])
    arch =  Architecture.find_by_name(params[:architecture])
    respond_to do |format|
      format.json { render :json => @operatingsystem.pxe_files(media, arch)}
    end
  rescue => e
    respond_to do |format|
      format.json { render :json => e.to_s, :status => :unprocessable_entity }
    end
  end

  private
  def find_os
    @operatingsystem = Operatingsystem.find(params[:id])
  end

end
