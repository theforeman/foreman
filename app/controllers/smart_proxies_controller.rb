class SmartProxiesController < ApplicationController

  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_resource, :only => [:edit, :update, :refresh, :ping, :destroy]

  def index
    @smart_proxies = resource_base.includes(:features).search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def new
    @smart_proxy = SmartProxy.new
  end

  def create
    @smart_proxy = SmartProxy.new(foreman_params)
    if @smart_proxy.save
      process_success :object => @smart_proxy
    else
      process_error :object => @smart_proxy
    end
  end

  def edit
    @proxy = @smart_proxy
  end

  def ping
    @proxy = @smart_proxy
    respond_to do |format|
      format.json {render :json => errors_hash(@smart_proxy.refresh)}
    end
  end

  def refresh
    old_features = @smart_proxy.features
    if @smart_proxy.refresh.blank? && @smart_proxy.save
      msg = @smart_proxy.features == old_features ? _("No changes found when refreshing features from %s.") : _("Successfully refreshed features from %s.")
      process_success :object => @smart_proxy, :success_msg => msg % @smart_proxy.name
    else
      process_error :object => @smart_proxy
    end
  end

  def update
    if @smart_proxy.update_attributes(foreman_params)
      process_success :object => @smart_proxy
    else
      process_error :object => @smart_proxy
    end
  end

  def destroy
    if @smart_proxy.destroy
      process_success :object => @smart_proxy
    else
      process_error :object => @smart_proxy
    end
  end

  private

  def action_permission
    case params[:action]
      when 'refresh'
        :edit
      when 'ping'
        :view
      else
        super
    end
  end
end
