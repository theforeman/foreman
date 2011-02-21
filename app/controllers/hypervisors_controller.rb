class HypervisorsController < ApplicationController
  def index
    respond_to do |format|
      format.html {@hypervisors = Hypervisor.all}
      format.json { render :json => Hypervisor.all }
    end
  end

  def new
    @hypervisor = Hypervisor.new
  end

  def create
    @hypervisor = Hypervisor.new(params[:hypervisor])
    if @hypervisor.save
      process_success
    else
      process_error
    end
  end

  def edit
    @hypervisor = Hypervisor.find(params[:id])
  end

  def update
    @hypervisor = Hypervisor.find(params[:id])
    if @hypervisor.update_attributes(params[:hypervisor])
      process_success
    else
      process_error
    end
  end

  def destroy
    @hypervisor = Hypervisor.find(params[:id])
    if @hypervisor.destroy
      process_success
    else
      process_error
    end
  end

end
