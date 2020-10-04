class ExternalIpamController < ApplicationController
  def show
    @proxy = SmartProxy.with_features('External IPAM').first
    @api = ProxyAPI::ExternalIpam.new({:url => @proxy.url}) if @proxy.present?

    if @proxy
      @subnets = @api.get_subnets_by_group(params[:group])
      render :json => @subnets.to_json, :status => :ok
    else
      flash.now[:error] = "No External IPAM Proxy configured"
    end
  rescue => e
    flash.now[:error] = e.message
  end
end
