class SettingsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :require_admin
  before_action :reload_settings, :only => :index, :unless => :dynamic_methods_exist?

  #This can happen in development when removing a plugin
  rescue_from ActiveRecord::SubclassNotFound do |e|
    type = (e.to_s =~ /\'(Setting::.*)\'\./) ? $1 : 'STI-Type'
    render :text => (e.to_s+"<br><b>run Setting.delete_all(:category=>'#{type}') to recover.</b>").html_safe, :status=> :internal_server_error
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

  private

  # reload settings when code reloads after change in development env
  def reload_settings
    Setting.descendants.each(&:load_defaults)
  end

  def dynamic_methods_exist?
    Setting::Puppet.instance_methods.any? { |w| w.to_s.include? "_collection" }
  end
end
