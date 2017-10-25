module Foreman::Controller::Parameters::NicBase
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::HostAlias

  class_methods do
    def add_nic_base_params_filter(filter)
      filter.permit_by_context :attached_devices, # accepts string or array
        :attached_to,
        :bond_options,
        :host, :host_id,
        :identifier,
        :ip,
        :ip6,
        :link,
        :mac,
        :managed,
        :mode,
        :name,
        :password,
        :primary,
        :provider,
        :provision,
        :type,
        :tag,
        :username,
        :virtual,
        {:attached_devices => []},
        {:compute_attributes => [:bridge, :from_profile, :model, :network, :type, :name]},
        {:host_aliases_attributes => [host_alias_params_filter]},
        :nested => true

      filter.permit_by_context :id,
        :_destroy,
        :ui => false, :api => false, :nested => true
    end
  end
end
