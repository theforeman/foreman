class SettingsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :require_admin

  #This can happen in development when removing a plugin
  rescue_from ActiveRecord::SubclassNotFound do |e|
    type = (e.to_s =~ /\'(Setting::.*)\'\./) ? $1 : 'STI-Type'
    render :text => (e.to_s+"<br><b>run Setting.delete_all(:category=>'#{type}') to recover.</b>").html_safe, :status=> :internal_server_error
  end

  def index
    @settings = Setting.live_descendants.search_for(params[:search])
  end

  def update
    @setting = Setting.find(params[:id])
    if @setting.parse_string_value(foreman_params[:value]) && @setting.save
      render :json => @setting
    else
      error_msg = @setting.errors.full_messages
      logger.error "Unprocessable entity Setting (id: #{@setting.id}):\n #{error_msg.join("\n  ")}\n"
      render :json => {"errors" => error_msg}, :status => :unprocessable_entity
    end
  end
end
