class SubnetsController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        @search = Subnet.search params[:search]
        @subnets = @search.paginate(:page => params[:page])
      end
      format.json {render :json => Subnet.all}
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
    not_found and return unless subnet = Subnet.find(s)

    if ip = subnet.unused_ip
      render :update do |page|
        page['host_ip'].value = ip
        page['indicator'].hide
        page['host_ip'].visual_effect :highlight
      end
    else
      # we don't want any failures if we failed to query our proxy
      head :status => 200
    end
  rescue => e
    logger.warn "Failed to query #{subnet} for free ip: #{e}"
    head :status => 500
  end

end
