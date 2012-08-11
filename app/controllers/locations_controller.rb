class LocationsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    respond_to do |format|
      format.html { @locations = Location.all }
    end
  end
end
