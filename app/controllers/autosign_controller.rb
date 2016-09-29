class AutosignController < ApplicationController
  def index
    find_proxy
    render :partial => 'autosign/list', :locals => { :autosign => @proxy.statuses[:puppetca].autosign }
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  def counts
    find_proxy
    render :partial => 'autosign/counts', :locals => { :autosign => @proxy.statuses[:puppetca].autosign }
  rescue Foreman::Exception => exception
    process_ajax_error exception
  end

  def new
    find_proxy(:create_smart_proxies_autosign)
    render :partial => 'autosign/form'
  end

  def create
    find_proxy(:create_smart_proxies_autosign)
    api_action(:set_autosign)
  end

  def destroy
    find_proxy(:destroy_smart_proxies_autosign)
    api_action(:del_autosign)
  end

  private

  def find_proxy(permission = :view_smart_proxies_autosign)
    @proxy = SmartProxy.authorized(permission).find(params[:smart_proxy_id])
  end

  def api_action(action)
    @proxy.statuses[:puppetca].public_send(action, params[:id])
    process_success({ :success_redirect => smart_proxy_path(@proxy, :anchor => 'autosign'),
                        :object_name => 'puppet autosign entry' })
  rescue => e
    process_error({:redirect => smart_proxy_path(@proxy, :anchor => 'autosign'), :error_msg => e.message})
  end

  def action_permission
    case params[:action]
      when 'counts'
        :view
      else
        super
    end
  end
end
