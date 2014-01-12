class SmartProxiesController < ApplicationController

  include Foreman::Controller::AutoCompleteSearch

  def index
    @smart_proxies = SmartProxy.authorized(:view_smart_proxies).includes(:features).paginate :page => params[:page]
  end

  def new
    @proxy = SmartProxy.new
  end

  def create
    @proxy = SmartProxy.new(params[:smart_proxy])
    if @proxy.save
      process_success :object => @proxy
    else
      process_error :object => @proxy
    end
  end

  def edit
    @proxy = find_by_id(:edit_smart_proxies)
  end

  def ping
    @proxy = find_by_id
    respond_to do |format|
      format.json {render :json => errors_hash(@proxy.refresh)}
    end
  end

  def refresh
    @proxy = find_by_id(:edit_smart_proxies)
    old_features = @proxy.features
    if @proxy.refresh.blank? && @proxy.save
      msg = @proxy.features == old_features ? _("No changes found when refreshing features from %s.") : _("Successfully refreshed features from %s.")
      process_success :object => @proxy, :success_msg => msg % @proxy.name
    else
      process_error :object => @proxy
    end
  end

  def update
    @proxy = find_by_id(:edit_smart_proxies)
    if @proxy.update_attributes(params[:smart_proxy])
      process_success :object => @proxy
    else
      process_error :object => @proxy
    end
  end

  def destroy
    @proxy = find_by_id(:destroy_smart_proxies)
    if @proxy.destroy
      process_success :object => @proxy
    else
      process_error :object => @proxy
    end
  end

  private
  def find_by_id(permission = :view_smart_proxies)
    SmartProxy.authorized(permission).find(params[:id])
  end
end
