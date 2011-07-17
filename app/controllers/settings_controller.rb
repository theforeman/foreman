class SettingsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :require_admin

  def index
    values = Setting.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html do
        @settings = values.paginate(:page => params[:page])
      end
      format.json { render :json => values.all}
    end
  end

  def edit
    @setting = Setting.find(params[:id])
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
