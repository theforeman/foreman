class PuppetcaController < ApplicationController
  def index
    find_proxy
    @certificates = @proxy.statuses[:puppetca].certs
    render :partial => 'puppetca/list'
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  def counts
    find_proxy
    @certificates = @proxy.statuses[:puppetca].certs
    render :partial => 'puppetca/counts'
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  def expiry
    find_proxy
    render :partial => 'puppetca/expiry', :locals => { :expiry => @proxy.statuses[:puppetca].expiry }
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  def update
    find_proxy(:edit_smart_proxies_puppetca)
    cert_action(:sign)
  end

  def destroy
    find_proxy(:destroy_smart_proxies_puppetca)
    cert_action(:destroy)
  end

  private

  def find_proxy(permission = :view_smart_proxies_puppetca)
    @proxy = SmartProxy.authorized(permission).find(params[:smart_proxy_id])
  end

  def cert_action(action)
    cert = @proxy.statuses[:puppetca].find(params[:id])
    cert.public_send(action)
    process_success(:success_redirect => smart_proxy_path(@proxy, :anchor => 'certificates'), :object_name => cert.to_s)
  rescue => e
    process_error(:redirect => smart_proxy_path(@proxy, :anchor => 'certificates'), :error_msg => e.message)
  end

  def action_permission
    case params[:action]
      when 'counts', 'expiry'
        :view
      else
        super
    end
  end
end
