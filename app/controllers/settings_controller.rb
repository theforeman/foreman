class SettingsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    @settings = Foreman.settings.search_for(params[:search])
  rescue ::Foreman::Exception => e
    @settings = Foreman.settings
    @search_error = e
  end
end
