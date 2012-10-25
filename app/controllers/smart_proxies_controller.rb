class SmartProxiesController < ApplicationController
  def index
    respond_to do |format|
      format.html {@proxies = SmartProxy.includes(:features).paginate :page => params[:page]}
      format.json {render :json => SmartProxy.all}
    end
  end

  def new
    @proxy = SmartProxy.new
  end

  def create
    @proxy = SmartProxy.new(params[:smart_proxy])
    @proxy.locations_ids = [Location.current.id] if Taxonomy.locations_enabled
    @proxy.organization_ids = [Organization.current.id] if Taxonomy.organizations_enabled
    if @proxy.save
      process_success :object => @proxy
    else
      process_error :object => @proxy
    end
  end

  def edit
    @proxy = SmartProxy.find(params[:id])
  end

  def update
    @proxy = SmartProxy.find(params[:id])
    if @proxy.update_attributes(params[:smart_proxy])
      process_success :object => @proxy
    else
      process_error :object => @proxy
    end
  end

  def destroy
    @proxy = SmartProxy.find(params[:id])
    if @proxy.destroy
      process_success :object => @proxy
    else
      process_error :object => @proxy
    end
  end
end
