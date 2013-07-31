class SettingsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :require_admin

  #This can happen in development when removing a plugin
  rescue_from ActiveRecord::SubclassNotFound do |e|
    render :text=> (e.to_s+"<br><b>run Setting.delete_all(:category=>'#{e.to_s.match(/\'(Setting::.*)\'\./)[1] rescue 'STI-Type'}') to recover.</b>").html_safe , :status=> 500
  end

  def index
    @settings = Setting.live_descendants.search_for(params[:search])
    respond_to do |format|
      format.html
      format.json { render :json => @settings.all}
    end
  end

  def update
    @setting = Setting.find(params[:id])
    if @setting.parse_string_value(params[:setting][:value]) && @setting.save
      process_success
    else
      process_error
    end
  end
end
