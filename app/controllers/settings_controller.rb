class SettingsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  helper_method :xeditable?

  def index
    @settings = Setting.live_descendants.search_for(params[:search])
  end

  def update
    @setting = Setting.friendly.find(params[:id])
    if @setting.parse_string_value(params[:setting][:value]) && @setting.save
      render :json => @setting
    else
      error_msg = @setting.errors.full_messages
      logger.error "Unprocessable entity Setting (id: #{@setting.id}):\n #{error_msg.join("\n  ")}\n"
      render :json => {"errors" => error_msg}, :status => :unprocessable_entity
    end
  end

  def xeditable?(object = nil, permission = nil)
    current_user.can? :edit_settings
  end
end
