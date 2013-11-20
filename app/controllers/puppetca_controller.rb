class PuppetcaController < ApplicationController

  def index
    @proxy = find_proxy
    # expire cache if forced
    Rails.cache.delete("ca_#{@proxy.id}") if params[:expire_cache] == "true"
    begin
      certs = if params[:state].blank?
                SmartProxies::PuppetCA.find_by_state(@proxy, "valid") + SmartProxies::PuppetCA.find_by_state(@proxy, "pending")
              elsif params[:state] == "all"
                SmartProxies::PuppetCA.all @proxy
              else
                SmartProxies::PuppetCA.find_by_state @proxy, params[:state]
              end
    rescue => e
      certs = []
      error e
      redirect_to :back and return
    end
    begin
      @certificates = certs.sort.paginate :page => params[:page], :per_page => params[:per_page] || 20
    rescue => e
      error e
    end
  end

  def update
    @proxy = find_proxy(:edit_smart_proxies_puppetca)
    cert = SmartProxies::PuppetCA.find(@proxy, params[:id])
    if cert.sign
      process_success({ :success_redirect => smart_proxy_puppetca_index_path(@proxy, :state => params[:state]), :object_name => cert.to_s })
    else
      process_error({ :redirect => smart_proxy_puppetca_index_path(@proxy) })
    end
  rescue
    process_error({ :redirect => smart_proxy_puppetca_index_path(@proxy) })
  end

  def destroy
    @proxy = find_proxy(:destroy_smart_proxies_puppetca)
    cert = SmartProxies::PuppetCA.find(@proxy, params[:id])
    if cert.destroy
      process_success({ :success_redirect => smart_proxy_puppetca_index_path(@proxy, :state => params[:state]), :object_name => cert.to_s })
    else
      process_error({ :redirect => smart_proxy_puppetca_index_path(@proxy) })
    end
  end

  private

  def find_proxy(permission = :view_smart_proxies_puppetca)
    SmartProxy.authorized(permission).find(params[:smart_proxy_id])
  end

end
