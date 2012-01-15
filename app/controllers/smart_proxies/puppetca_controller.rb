class SmartProxies::PuppetcaController < ApplicationController
  before_filter :find_proxy

  def index

    # expire cache if forced
    Rails.cache.delete("ca_#{@proxy.id}") if params[:expire_cache] == "true"

    begin
      if params[:state].blank?
        certificates = SmartProxies::PuppetCA.all @proxy
      else
        certificates = SmartProxies::PuppetCA.find_by_state @proxy, params[:state]
      end
    rescue => e
      certificates = []
      error e
      redirect_to :back and return
    end
    respond_to do |format|
      format.html do
        begin
          @certificates = certificates.sort.paginate :page => params[:page], :per_page => 20
        rescue => e
          error e
        end
      end
      format.json { render :json => certificates }
    end
  end

  def update
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
    cert = SmartProxies::PuppetCA.find(@proxy, params[:id])
    if cert.destroy
      process_success({ :success_redirect => smart_proxy_puppetca_index_path(@proxy, :state => params[:state]), :object_name => cert.to_s })
    else
      process_error({ :redirect => smart_proxy_puppetca_index_path(@proxy) })
    end
  end

  private

  def find_proxy
    @proxy = SmartProxy.find(params[:smart_proxy_id])
  end

end
