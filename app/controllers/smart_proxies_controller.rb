class SmartProxiesController < ApplicationController
  def index
    respond_to do |format|
      format.html {@proxies = SmartProxy.paginate :page => params[:page]}
      format.json {render :json => SmartProxy.all}
    end
  end

  def new
    @proxy = SmartProxy.new
  end

  def create
    @proxy = SmartProxy.new(params[:smart_proxy])
    Taxonomy.when_single_taxonomy do
      @proxy.taxonomy_ids = [Taxonomy.current.id]
    end
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
