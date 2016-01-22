class SmartProxiesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_resource, :only => [:show, :edit, :update, :refresh, :ping, :tftp_server, :destroy]
  before_filter :find_status, :only => [:ping, :tftp_server]

  def index
    @smart_proxies = resource_base.includes(:features).search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
  end

  def show
  end

  def new
    @smart_proxy = SmartProxy.new
  end

  def create
    @smart_proxy = SmartProxy.new(params[:smart_proxy])
    if @smart_proxy.save
      process_success :object => @smart_proxy
    else
      process_error :object => @smart_proxy
    end
  end

  def edit
    @proxy = @smart_proxy
  end

  def refresh
    old_features = @smart_proxy.features.to_a
    if @smart_proxy.refresh
      msg = @smart_proxy.features.to_a == old_features ? _("No changes found when refreshing features from %s.") : _("Successfully refreshed features from %s.")
      process_success :object => @smart_proxy, :success_msg => msg % @smart_proxy.name
    else
      process_error :object => @smart_proxy
    end
  end

  def ping
    requested_data do
      @proxy_status[:version].version
    end
  end

  def tftp_server
    if @proxy_status[:tftp]
      requested_data do
        @proxy_status[:tftp].server
      end
    else
      render(:json => {:success => false, :message => _('No TFTP feature')})
    end
  end

  def update
    if @smart_proxy.update_attributes(params[:smart_proxy])
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

  def find_status
    @proxy_status = @smart_proxy.statuses
  end

  def requested_data
    data = yield
    render :json => {:success => true, :message => data }
  rescue Foreman::Exception => exception
    render :json => {:success => false, :message => exception.message} and return
  end

  def action_permission
    case params[:action]
      when 'refresh'
        :edit
      when 'ping', 'tftp_server'
        :view
      else
        super
    end
  end
end
