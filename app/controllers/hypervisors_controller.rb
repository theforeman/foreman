class HypervisorsController < ApplicationController
  before_filter :find_by_name, :only => [:show, :edit, :update, :destroy]
  before_filter :connect_to_hypervisor, :only => :show
  after_filter :disconnect_from_hypervisor, :only => :show

  def index
    respond_to do |format|
      format.html {@hypervisors = Hypervisor.paginate :page => params[:page]}
      format.json { render :json => Hypervisor.all }
    end
  end

  def new
    @hypervisor = Hypervisor.new
  end

  def show
    respond_to do |format|
      format.html {}
      format.json { render :json => @hypervisor }
    end
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
  end

  def update
    if @hypervisor.update_attributes(params[:hypervisor])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @hypervisor.destroy
      process_success
    else
      process_error
    end
  end

  private

  def connect_to_hypervisor
    @host = @hypervisor.connect
  end

  def disconnect_from_hypervisor
    @hypervisor.disconnect
  end

end
