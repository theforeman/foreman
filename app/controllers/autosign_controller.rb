class AutosignController < ApplicationController

  def index
    @proxy = SmartProxy.authorized(:view_smart_proxies_autosign).find(params[:smart_proxy_id])
    setup_proxy

    begin
      autosign = @api.autosign
    rescue => e
      autosign = []
      error e
    end
    @autosign = autosign.paginate :page => params[:page], :per_page => 20
  end

  def new
    @proxy = SmartProxy.authorized(:create_smart_proxies_autosign).find(params[:smart_proxy_id])
    setup_proxy
  end

  def create
    @proxy = SmartProxy.authorized(:create_smart_proxies_autosign).find(params[:smart_proxy_id])
    setup_proxy

    if @api.set_autosign(params[:id])
      process_success({:success_redirect => smart_proxy_autosign_index_path(@proxy), :object_name => 'puppet autosign entry'})
    else
      process_error({:redirect => smart_proxy_autosign_index_path(@proxy)})
    end
  end

  def destroy
    @proxy = SmartProxy.authorized(:destroy_smart_proxies_autosign).find(params[:smart_proxy_id])
    setup_proxy

    if @api.del_autosign(params[:id])
      process_success({:success_redirect => smart_proxy_autosign_index_path(@proxy), :object_name => 'puppet autosign entry'})
    else
      process_error({:redirect => smart_proxy_autosign_index_path(@proxy)})
    end
  end

  private

  def setup_proxy
    @api = ProxyAPI::Puppetca.new({:url => @proxy.url})
  end
end
