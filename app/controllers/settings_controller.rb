class SettingsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    @settings = Setting.live_descendants.search_for(params[:search])
  end
end
