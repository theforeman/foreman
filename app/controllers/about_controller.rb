class AboutController < ApplicationController
  skip_before_action :authorize, :only => :index

  def index
    @smart_proxies = SmartProxy.authorized(:view_smart_proxies).includes(:features)
    @compute_resources = ComputeResource.authorized(:view_compute_resources)
    @plugins = Foreman::Plugin.all

    enabled_providers = ComputeResource.providers.keys
    @providers = ComputeResource.all_providers.map do |provider_name, provider_class|
      {
        :friendly_name => provider_class.constantize.provider_friendly_name,
        :name => provider_name,
        :status => enabled_providers.include?(provider_name) ? :installed : :absent,
      }
    end
  end
end
