class HypervisorsController < ApplicationController
  def index
    @hypervisors = Hypervisor.all
  end

  def new
    @hypervisor = Hypervisor.new
  end

  def create
    @hypervisor = Hypervisor.new(params[:hypervisor])
    if @hypervisor.save
      notice = "Successfully created hypervisor."
      redirect_to hypervisors_url
    else
      render :action => 'new'
    end
  end

  def edit
    @hypervisor = Hypervisor.find(params[:id])
  end

  def update
    @hypervisor = Hypervisor.find(params[:id])
    if @hypervisor.update_attributes(params[:hypervisor])
      notice = "Successfully updated hypervisor."
      redirect_to hypervisors_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @hypervisor = Hypervisor.find(params[:id])
    @hypervisor.destroy
    notice = "Successfully destroyed hypervisor."
    redirect_to hypervisors_url
  end

end
