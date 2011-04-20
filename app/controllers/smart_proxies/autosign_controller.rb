require_dependency "proxy_api"

class SmartProxies::AutosignController < ApplicationController
  before_filter :find_proxy, :setup_proxy

  def index
    begin
      autosign = @api.autosign
    rescue => e
      autosign = []
      error e
    end
    respond_to do |format|
      format.html { @autosign = autosign.paginate :page => params[:page], :per_page => 20 }
      format.json {render :json => autosign }
    end
  end

  def new
  end

  def create
    if @api.set_autosign(params[:id])
      process_success({:success_redirect => smart_proxy_autosign_index_path(@proxy), :object_name => 'puppet autosign entry'})
    else
      process_error({:redirect => smart_proxy_autosign_index_path(@proxy)})
    end
  end

  def destroy
    if @api.del_autosign(params[:id])
      process_success({:success_redirect => smart_proxy_autosign_index_path(@proxy), :object_name => 'puppet autosign entry'})
    else
      process_error({:redirect => smart_proxy_autosign_index_path(@proxy)})
    end
  end

  private

  def find_proxy
    @proxy = SmartProxy.find(params[:smart_proxy_id])
  end

  def setup_proxy
    @api = ProxyAPI::Puppetca.new({:url => @proxy.url})
  end
end
