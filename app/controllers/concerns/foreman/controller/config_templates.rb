module Foreman::Controller::ConfigTemplates
  extend ActiveSupport::Concern

  def load_vars_from_config_template
    return unless @config_template

    @locations        = @config_template.locations
    @organizations    = @config_template.organizations
    @template_kind_id = @config_template.template_kind_id
    @operatingsystems = @config_template.operatingsystems
  end

  private

  def default_template_url(template, hostgroup)
    url_for(:host => Setting[:unattended_url], :action => :template, :controller => '/unattended',
            :id => template.name, :hostgroup => hostgroup.name)
  end

  # convert the file upload into a simple string to save in our db.
  def handle_template_upload
    return unless params[:config_template] && (template = params[:config_template][:template])
    params[:config_template][:template] = template.read if template.respond_to?(:read)
  end

  def process_template_kind
    return unless params[:config_template] && (template_kind = params[:config_template].delete(:template_kind))
    params[:config_template][:template_kind_id] = template_kind[:id]
  end
end
