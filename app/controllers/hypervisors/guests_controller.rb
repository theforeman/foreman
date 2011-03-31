class Hypervisors::GuestsController < ApplicationController
  before_filter :find_hypervisor
  after_filter :disconnect_from_hypervisor

  def index
    @guests = @hypervisor.guests.paginate :page => params[:page]
  end

  def power
    @guest = @hypervisor.find_guest_by_name params[:id]
    action = @guest.running? ? :stop : :start

    if (@guest.send(action) rescue false)
      state = @guest.running? ? "running" : "stopped"
      notice "#{@guest.name} is now #{state}"
      redirect_to hypervisor_guests_path params[:hypervisor_id]
    else
      error "failed to #{action} #{@guest.name}"
      redirect_to :back
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

end
