class SmartProxyPoolsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::SmartProxyPool

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    @smart_proxy_pools = resource_base_search_and_page
  end

  def new
    @smart_proxy_pool = SmartProxyPool.new
  end

  def create
    @smart_proxy_pool = SmartProxyPool.new(smart_proxy_pool_params)
    if @smart_proxy_pool.save
      process_success :object => @smart_proxy_pool
    else
      process_error :object => @smart_proxy_pool
    end
  end

  def edit
  end

  def update
    if @smart_proxy_pool.update(smart_proxy_pool_params)
      process_success :object => @smart_proxy_pool
    else
      process_error :object => @smart_proxy_pool
    end
  end

  def destroy
    if @smart_proxy_pool.destroy
      process_success :object => @smart_proxy_pool, :success_redirect => smart_proxy_pools_path
    else
      process_error :object => @smart_proxy_pool
    end
  end
end
