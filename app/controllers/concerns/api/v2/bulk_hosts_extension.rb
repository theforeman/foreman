module Api::V2::BulkHostsExtension
  extend ActiveSupport::Concern

  def bulk_hosts_relation(permission, org)
    relation = ::Host::Managed.authorized(permission)
    relation = relation.where(organization: org) if org
    relation
  end

  def find_bulk_hosts(permission, bulk_params, restrict_to = nil)
    # works on a structure of param_group bulk_params and transforms it into a list of systems
    bulk_params[:included] ||= {}
    bulk_params[:excluded] ||= {}
    search_param = bulk_params[:included][:search] || bulk_params[:search]

    if !params[:install_all] && bulk_params[:included][:ids].blank? && search_param.nil?
      render_error :custom_error, :status => :bad_request, :locals => { :message => _('No hosts have been specified') }
    end

    find_organization
    @hosts = bulk_hosts_relation(permission, @organization)

    if bulk_params[:included][:ids].present?
      @hosts = @hosts.where(id: bulk_params[:included][:ids])
    end

    if search_param.present?
      @hosts = @hosts.search_for(search_param)
    end

    @hosts = restrict_to.call(@hosts) if restrict_to

    if bulk_params[:excluded][:ids].present?
      @hosts = @hosts.where.not(id: bulk_params[:excluded][:ids])
    end
    if @hosts.empty?
      render_error :custom_error, :status => :forbidden, :locals => { :message => _('No hosts matched search, or action unauthorized for selected hosts.') }
    end
    @hosts
  end

  def find_organization
    @organization ||= Organization.find_by_id(params[:organization_id])
  end
end
