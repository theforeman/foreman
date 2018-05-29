class SubnetsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Subnet

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    @subnets = resource_base_search_and_page([:domains, :dhcp])
    @subnets = @subnets.network_reorder(params[:order]) if params[:order].present? && params[:order] =~ /\Anetwork( ASC| DESC)?\Z/
  end

  def new
    @subnet = Subnet.new
  end

  def create
    @subnet = Subnet.new(subnet_params.except(:mask))
    if @subnet.save
      process_success success_hash
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @subnet.update(subnet_params.except(:mask))
      process_success success_hash
    else
      process_error
    end
  end

  def destroy
    if @subnet.destroy
      process_success success_hash
    else
      process_error
    end
  end

  # query our subnet dhcp proxy for an unused IP
  def freeip
    unless (s = params[:subnet_id].to_i) > 0
      invalid_request
      return
    end
    organization = params[:organization_id].blank? ? nil : Organization.find(params[:organization_id])
    location = params[:location_id].blank? ? nil : Location.find(params[:location_id])
    Taxonomy.as_taxonomy organization, location do
      unless (subnet = Subnet.authorized(:view_subnets).find(s))
        not_found
        return
      end
      unless (ipam = subnet.unused_ip(params[:host_mac], params[:taken_ips])).present?
        not_found
        return
      end
      ip = ipam.suggest_ip
      render :json => {:ip => ip, :errors => ipam.errors}
    end
  rescue => e
    logger.warn "Failed to query subnet #{s} for free ip: #{e}"
    process_ajax_error(e, "get free ip")
  end

  def import
    proxy = SmartProxy.find(params[:smart_proxy_id])
    @subnets = Subnet::Ipv4.import(proxy)
    if @subnets.empty?
      warning _("No new IPv4 subnets found")
      redirect_to :subnets
    end
  end

  def create_multiple
    if params[:subnets].empty?
      return redirect_to subnets_path, :success => _("No IPv4 subnets selected")
    end

    params_filter = self.class.subnet_params_filter
    subnet_attrs = params[:subnets].map do |subnet_param|
      params_filter.filter_params(subnet_param, parameter_filter_context, :none)
    end
    @subnets = Subnet.create(subnet_attrs).reject { |s| s.errors.empty? }
    if @subnets.empty?
      process_success(:object => @subnets, :success_msg => _("Imported IPv4 Subnets"))
    else
      render :action => "import"
    end
  end

  private

  def success_hash
    { :success_redirect => params[:redirect].presence }
  end
end
