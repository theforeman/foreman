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
end
