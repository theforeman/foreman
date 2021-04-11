class SettingsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    @settings = Foreman.settings.search_for(params[:search])
  end
end
