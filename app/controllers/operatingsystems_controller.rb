class OperatingsystemsController < ApplicationController
  def index
    @operatingsystems = Operatingsystem.all(:include => [:architectures], :order => :name)
  end

  def new
    @operatingsystem = Operatingsystem.new
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
    @operatingsystem = Operatingsystem.find(params[:id])
  end

  def update
    @operatingsystem = Operatingsystem.find(params[:id])
    if @operatingsystem.update_attributes(params[:operatingsystem])
      flash[:foreman_notice] = "Successfully updated operatingsystem."
      redirect_to operatingsystems_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @operatingsystem = Operatingsystem.find(params[:id])
    if @operatingsystem.destroy
      flash[:foreman_notice] = "Successfully destroyed operatingsystem."
    else
      flash[:foreman_error] = @operatingsystem.errors.full_messages.join("<br>")
    end
    redirect_to operatingsystems_url
  end
end
