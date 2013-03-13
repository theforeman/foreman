class SubnetsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def index
    values = Subnet.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html { @subnets = values.includes(:domains, :dhcp).paginate :page => params[:page] }
      format.json { render :json => values }
    end
  end

  def new
    @subnet = Subnet.new
  end

  def create
    @subnet = Subnet.new(params[:subnet])
    if @subnet.save
      process_success
    else
      process_error
    end
  end

  def edit
    @subnet = Subnet.find(params[:id])
  end

  def update
    @subnet = Subnet.find(params[:id])
    if @subnet.update_attributes(params[:subnet])
      process_success
    else
      process_error
    end
  end

  def destroy
    @subnet = Subnet.find(params[:id])
    if @subnet.destroy
      process_success
    else
      process_error
    end
  end

  # query our subnet dhcp proxy for an unused IP
  def freeip
    not_found and return unless (s=params[:subnet_id].to_i) > 0
    organization = params[:organization_id].blank? ? nil : Organization.find(params[:organization_id])
    location = params[:location_id].blank? ? nil : Location.find(params[:location_id])
    Taxonomy.as_taxonomy organization, location do
      not_found and return unless (subnet = Subnet.find(s))
      if (ip = subnet.unused_ip(params[:host_mac]))
        render :json => {:ip => ip}
      else
        # we don't want any failures if we failed to query our proxy
        head :status => 200
      end
    end
  rescue => e
    logger.warn "Failed to query #{subnet} for free ip: #{e}"
    head :status => 500
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
      return redirect_to subnets_path, :notice => _("No Subnets selected")
    end

    @subnets = Subnet.create(params[:subnets]).reject { |s| s.errors.empty? }
    if @subnets.empty?
      process_success(:object => @subnets, :success_msg => _("Imported Subnets"))
    else
      render :action => "import"
    end
  end

end
