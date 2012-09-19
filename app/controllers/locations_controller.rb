class LocationsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    begin
      # TODO: Get the locations that belong to the current user
      locations = User.current.admin? ? Location :  Location
      values = locations.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
    end

    respond_to do |format|
      format.html do
        @locations = values.paginate :page => params[:page]
      end
    end
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(params[:location])

    if @location.save
      process_success
    else
      process_error
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])

    if @location.update_attributes(params[:location])
      process_success
    else
      process_error
    end
  end

  def destroy
    @location = Location.find(params[:id])

    if @location.destroy
      process_success
    else
      process_error
    end
  end

  def load_vars_for_ajax
    return unless @location
  end
end
