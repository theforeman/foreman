require_dependency 'hypervisor/guest'

class Hypervisors::GuestsController < ApplicationController
  before_filter :find_hypervisor
  before_filter :find_guest, :only => [:show, :power, :destroy]
  after_filter :disconnect_from_hypervisor

  def index
    @guests = @hypervisor.guests.paginate :page => params[:page]
    respond_to do |format|
      format.html
      format.json { render :json => @guests }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :json => @guest }
    end
  end

  def power
    action = @guest.running? ? :stop : :start

    if (@guest.send(action) rescue false)
      state = @guest.running? ? "running" : "stopped"
      notice "#{@guest.name} is now #{state}"
      redirect_to hypervisor_guests_path(params[:hypervisor_id])
    else
      error "failed to #{action} #{@guest.name}"
      redirect_to :back
    end
  end

  def destroy
    if @guest.volume.destroy and @guest.destroy
      process_success({:success_redirect => hypervisor_guests_path(@hypervisor)})
    else
      process_error({:redirect => hypervisor_guests_path(@hypervisor)})
    end
 end

  private

  def find_hypervisor
    @hypervisor = Hypervisor.find_by_name(params[:hypervisor_id])
    @hypervisor.connect if @hypervisor
  end

  def disconnect_from_hypervisor
    @hypervisor.disconnect if @hypervisor
  end

  def find_guest
    @guest = Virt::Guest.find(params[:id])
  end

end
