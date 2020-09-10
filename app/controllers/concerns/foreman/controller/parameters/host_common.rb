module Foreman::Controller::Parameters::HostCommon
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::LookupValue
  include Foreman::Controller::Parameters::Parameter
  include Foreman::Controller::Parameters::SmartProxiesCommon

  class_methods do
    def add_host_common_params_filter(filter)
      filter.permit :compute_profile, :compute_profile_id, :compute_profile_name,
        :grub_pass,
        :image_id, :image_name,
        :image_file,
        :lookup_value_matcher,
        :use_image,
        :lookup_values_attributes => [lookup_value_params_filter]
      add_smart_proxies_common_params_filter(filter)
    end
  end
end
