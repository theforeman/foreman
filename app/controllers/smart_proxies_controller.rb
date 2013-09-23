class SmartProxiesController < ApplicationController
  before_filter :find_by_id, :only => [:edit, :update, :destroy, :ping, :refresh]
  def index
    @proxies = SmartProxy.includes(:features).paginate :page => params[:page]
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
  end

  def ping
    respond_to do |format|
      format.json {render :json => errors_hash(@proxy.refresh)}
    end
  end

  def refresh
    old_features = @proxy.features
    if @proxy.refresh.blank? && @proxy.save
      msg = @proxy.features == old_features ? _("No changes found when refreshing features from %s.") : _("Successfully refreshed features from %s.")
      process_success :object => @proxy, :success_msg => msg % @proxy.name
    else
      process_error :object => @proxy
    end
  end

  def update
    if @proxy.update_attributes(params[:smart_proxy])
      process_success :object => @proxy
    else
      process_error :object => @proxy
    end
  end

  def destroy
    if @proxy.destroy
      process_success :object => @proxy
    else
      process_error :object => @proxy
    end
  end

  private
  def find_by_id
    @proxy = SmartProxy.find(params[:id])
  end
end
