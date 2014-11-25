class SubnetsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    @subnets = resource_base.search_for(params[:search], :order => params[:order]).includes(:domains, :dhcp).paginate :page => params[:page]
  end

  def new
    @subnet = Subnet.new
  end

  def create
    @subnet = Subnet.new(foreman_params)
    if @subnet.save
      process_success success_hash
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @subnet.update_attributes(foreman_params)
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
    invalid_request and return unless (s=params[:subnet_id].to_i) > 0
    organization = params[:organization_id].blank? ? nil : Organization.find(params[:organization_id])
    location = params[:location_id].blank? ? nil : Location.find(params[:location_id])
    Taxonomy.as_taxonomy organization, location do
      not_found and return unless (subnet = Subnet.authorized(:view_subnets).find(s))
      if (ip = subnet.unused_ip(params[:host_mac], params[:taken_ips]))
        render :json => {:ip => ip}
      else
        not_found
      end
    end
  rescue => e
    logger.warn "Failed to query subnet #{s} for free ip: #{e}"
    process_ajax_error(e, "get free ip")
  end

  def import
    proxy = SmartProxy.find(params[:smart_proxy_id])
    @subnets = Subnet.import(proxy)
    if @subnets.empty?
      flash[:warning] = _("No new subnets found")
      redirect_to :subnets
    end
  end

  def create_multiple
    if params[:subnets].empty?
      return redirect_to subnets_path, :notice => _("No subnets selected")
    end

    @subnets = Subnet.create(params[:subnets]).reject { |s| s.errors.empty? }
    if @subnets.empty?
      process_success(:object => @subnets, :success_msg => _("Imported Subnets"))
    else
      render :action => "import"
    end
  end

  private

  def success_hash
    { :success_redirect => params[:redirect].present? ? params[:redirect] : nil }
  end
end
