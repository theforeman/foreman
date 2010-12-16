class SubnetsController < ApplicationController
  def index
    @search = Subnet.search params[:search]
    @subnets = @search.paginate(:page => params[:page])
  end

  def new
    @subnet = Subnet.new
  end

  def create
    @subnet = Subnet.new(params[:subnet])
    if @subnet.save
      notice "Successfully created subnet."
      redirect_to subnets_url
    else
      render :action => 'new'
    end
  end

  def edit
    @subnet = Subnet.find(params[:id])
  end

  def update
    @subnet = Subnet.find(params[:id])
    if @subnet.update_attributes(params[:subnet])
      notice "Successfully updated subnet."
      redirect_to subnets_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @subnet = Subnet.find(params[:id])
    @subnet.destroy
    notice "Successfully destroyed subnet."
    redirect_to subnets_url
  end

  # query our subnet dhcp proxy for an unused IP
  def freeip
    not_found and return unless s=params[:subnet_id].to_i > 0
    not_found and return unless subnet = Subnet.find(s)

    if ip = subnet.unused_ip
      render :update do |page|
        page['host_ip'].value = ip
        page['indicator'].hide
        page['host_ip'].visual_effect :highlight
      end
    end
    # we don't want any failures if we failed to query our proxy
  rescue => e
    logger.warn "failed to query #{subnet} for free ip: #{e}"
    head :status => 500
  end

end
