class UserdataController < ApplicationController
  include ::Foreman::Controller::TemplateRendering

  layout false

  skip_before_action :require_login, :check_user_enabled, :session_expiry, :update_activity_time, :set_taxonomy, :authorize, :verify_authenticity_token

  before_action :set_admin_user
  before_action :skip_secure_headers
  before_action :skip_session
  before_action :find_host

  def userdata
    render_userdata_template
  end

  def metadata
    data = {
      :'instance-id' => "i-#{Digest::SHA1.hexdigest(@host.id.to_s)[0..17]}",
      :hostname => @host.name,
      :mac => @host.mac,
      :'local-ipv4' => @host.ip,
      :'local-hostname' => @host.name,
    }
    render plain: data.map { |key, value| "#{key}: #{value}" }.join("\n")
  end

  private

  def render_userdata_template
    template = @host.provisioning_template(kind: 'cloud-init')
    template ||= @host.provisioning_template(kind: 'user_data')
    unless template
      render_error(
        _('Unable to find user-data or cloud-init template for host %{host} running %{os}'),
        :status => :not_found,
        :host => @host.name,
        :os => @host.operatingsystem
      )
      return
    end
    safe_render(template)
  end

  def skip_secure_headers
    SecureHeaders.opt_out_of_all_protection(request)
  end

  def skip_session
    request.session_options[:skip] = true
  end

  def find_host
    query_params = {
      ip: request.remote_ip,
    }

    @host = Foreman::UnattendedInstallation::HostFinder.new(query_params: query_params).search

    return true if @host
    render_error(_('Could not find host for request %{request_ip}'),
      :status => :not_found,
      :request_ip => request.remote_ip
    )
    false
  end
end
