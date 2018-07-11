class SettingsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  helper_method :xeditable?

  # This can happen in development when removing a plugin
  rescue_from ActiveRecord::SubclassNotFound do |e|
    type = (e.to_s =~ /\'(Setting::.*)\'\./) ? Regexp.last_match(1) : 'STI-Type'
    render :plain => (e.to_s + "<br><b>run Setting.where(:category=>'#{type}').delete_all to recover.</b>").html_safe, :status => :internal_server_error
  end

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
