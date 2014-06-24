class AboutController < ApplicationController
  skip_before_filter :authorize, :only => :index

  def index
    @smart_proxies = SmartProxy.authorized(:view_smart_proxies).includes(:features)
    @compute_resources = ComputeResource.authorized(:view_compute_resources)
    @plugins = Foreman::Plugin.all
  end

end
