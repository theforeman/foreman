# This module provides a method that exposes parameter information for a given host.
# The hash is extensible, so any plugin/module can add a provider that will add its
# information to the method.
# Usage:
# host = Host::Managed.find(my_host_id)
# host.info
# => A hash of hashes that describes all parameters associated with the host.
#
# Writing an extension:
# Inherit HostInfo::Provider and override #host_info method and register the
# provider by calling HostInfo.register_info_provider
module HostInfoExtensions
  extend ActiveSupport::Concern

  included do
    # Add default providers
    HostInfo.register_info_provider(HostInfoProviders::StaticInfo)
    HostInfo.register_info_provider(HostInfoProviders::ConfigGroupsInfo)
    HostInfo.register_info_provider(HostInfoProviders::PuppetInfo)
    HostInfo.register_info_provider(HostInfoProviders::HostParamsInfo)
  end
end
