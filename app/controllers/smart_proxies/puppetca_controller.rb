class SmartProxies::PuppetcaController < ApplicationController
  before_filter :find_proxy

  def index
    begin
      certificates = SmartProxies::PuppetCA.all(@proxy)
    rescue => e
      certificates = []
      error e
    end
    respond_to do |format|
      format.html do
        begin
          @certificates = certificates.paginate :page => params[:page], :per_page => 20
        rescue => e
          error e
        end
      end
      format.json { render :json => certificates }
    end
  end

  def create

  end

  def destroy
    cert = SmartProxies::PuppetCA.find(@proxy, params[:id])
    if cert.destroy
      process_success({ :success_redirect => smart_proxy_puppetca_index_path(@proxy) })
    else
      process_error({ :redirect => smart_proxy_puppetca_index_path(@proxy) })
    end
  end

  private

  def find_proxy
    @proxy = SmartProxy.find(params[:smart_proxy_id])
  end

end
