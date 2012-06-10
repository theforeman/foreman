module FogExtensions
end

begin
  require 'fog'

  Fog::Model.send(:include, FogExtensions::Model)

  require 'fog/aws'
  require 'fog/aws/models/compute/flavor'
  Fog::Compute::AWS::Flavor.send(:include, FogExtensions::AWS::Flavor)

  require 'fog/libvirt'
  require 'fog/libvirt/models/compute/server'
  Fog::Compute::Libvirt::Server.send(:include, FogExtensions::Libvirt::Server)

  require 'fog/ovirt'
  require 'fog/ovirt/models/compute/server'
  Fog::Compute::Ovirt::Server.send(:include, FogExtensions::Ovirt::Server)

  require 'fog/ovirt/models/compute/volume'
  Fog::Compute::Ovirt::Volume.send(:include, FogExtensions::Ovirt::Volume)

rescue LoadError
  Rails.logger.info "Fog is not installed - unable to manage compute resources"
rescue => exception
  Rails.logger.warn "Fog initialization failed - #{exception}"
  Rails.logger.debug exception.join("\n")
end
