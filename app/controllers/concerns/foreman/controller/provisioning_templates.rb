module Foreman::Controller::ProvisioningTemplates
  extend ActiveSupport::Concern

  def load_vars_from_template
    return unless @template

    @locations        = @template.locations
    @organizations    = @template.organizations
    @template_kind_id = @template.template_kind_id
    @operatingsystems = @template.operatingsystems if @template.respond_to?(:operatingsystems)
  end

  def find_global_registration
    template_name = Setting[:default_global_registration_item]
    @provisioning_template = ProvisioningTemplate.unscoped.find_by(name: template_name)
    @global_registration_vars = global_registration_vars if @provisioning_template
  end

  private

  def default_template_url(template, hostgroup)
    uri      = URI.parse(Setting[:unattended_url])
    host     = uri.host
    port     = uri.port
    protocol = uri.scheme

    url_for(:only_path => false, :action => :hostgroup_template, :controller => '/unattended',
            :id => template.name, :hostgroup => hostgroup.title, :protocol => protocol,
            :host => host, :port => port)
  end

  # convert the file upload into a simple string to save in our db.
  def handle_template_upload
    return unless params[type_name_singular] && (template = params[type_name_singular][:template])
    params[type_name_singular][:template] = template.read if template.respond_to?(:read)
  end

  def process_template_kind
    return unless params[type_name_singular] && (template_kind = params[type_name_singular].delete(:template_kind))
    params[type_name_singular][:template_kind_id] = template_kind[:id]
  end

  def type_name_singular
    @type_name_singular ||= resource_class.to_s.underscore
  end

  def global_registration_vars
    permitted = Foreman::Plugin.all
                               .map(&:allowed_registration_vars)
                               .flatten.compact.uniq

    organization = Organization.authorized(:view_organizations).find(params['organization_id']) if params['organization_id'].present?
    location = Location.authorized(:view_locations).find(params['location_id']) if params['location_id'].present?
    host_group = Hostgroup.authorized(:view_hostgroups).find(params['hostgroup_id']) if params["hostgroup_id"].present?

    {
      user: User.current,
      auth_token: User.current.jwt_token!(expiration: 4.hours.to_i),
      organization: organization,
      location: location,
      hostgroup: host_group,
      insecure: ActiveRecord::Type::Boolean.new.deserialize(params['insecure']),
    }.merge(params.permit(permitted).to_h.symbolize_keys)
  end
end
