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
      flash[:foreman_notice] = "Successfully created operatingsystem."
      redirect_to operatingsystems_url
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @operatingsystem.update_attributes(params[:operatingsystem])
      flash[:foreman_notice] = "Successfully updated operatingsystem."
      redirect_to operatingsystems_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @operatingsystem.destroy
      flash[:foreman_notice] = "Successfully destroyed operatingsystem."
    else
      flash[:foreman_error] = @operatingsystem.errors.full_messages.join("<br/>")
    end
    redirect_to operatingsystems_url
  end

  private
  def find_os
    @operatingsystem = Operatingsystem.find(params[:id])
  end

end
