class HttpProxiesController < ApplicationController
  include Foreman::Controller::Parameters::HttpProxy
  include Foreman::Controller::AutoCompleteSearch
  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    @http_proxies = resource_base_search_and_page
  end

  def new
    @http_proxy = HttpProxy.new
  end

  def create
    @http_proxy = HttpProxy.new(http_proxy_params)
    if @http_proxy.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def test_connection
    http_proxy = HttpProxy.new(http_proxy_params)
    http_proxy.test_connection(params[:test_url])

    render :json => {:status => 'success', :message => _("HTTP Proxy connection successful.")}, :status => :ok
  rescue => e
    render :json => {:status => 'failure', :message => e.message}, :status => :unprocessable_entity
  end

  def update
    if @http_proxy.update(http_proxy_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @http_proxy.destroy
      process_success
    else
      process_error
    end
  end
end
