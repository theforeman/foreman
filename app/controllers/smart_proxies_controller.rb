class SmartProxiesController < ApplicationController
  def index
    @proxies = SmartProxy.all
  end

  def new
    @proxy = SmartProxy.new
  end

  def create
    @proxy = SmartProxy.new(params[:smart_proxy])
    if @proxy.save
      notice "Successfully created a new smart proxy."
      redirect_to smart_proxies_url
    else
      render :action => 'new'
    end
  end

  def edit
    @proxy = SmartProxy.find(params[:id])
  end

  def update
    @proxy = SmartProxy.find(params[:id])
    if @proxy.update_attributes(params[:smart_proxy])
      notice "Successfully updated proxy."
      redirect_to smart_proxies_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @proxy = SmartProxy.find(params[:id])
    @proxy.destroy
    notice = "Successfully destroyed proxy."
    redirect_to smart_proxies_url
  end
end
