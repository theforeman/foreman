class AboutController < ApplicationController
  skip_before_filter :authorize, :only => :index

  def index
    @proxies = SmartProxy.my_proxies.includes(:features)
    @compute_resources = ComputeResource.my_compute_resources
  end

end
