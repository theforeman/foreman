class SettingsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :require_admin

  def index
    @settings = Setting.live_descendants.search_for(params[:search])
    respond_to do |format|
      format.html
      format.json { render :json => @settings.all}
    end
  end

  def update
    @setting = Setting.find(params[:id])
    if @setting.update_attributes(params[:setting])
      process_success
    else
      process_error
    end
  end
end
