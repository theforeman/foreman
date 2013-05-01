module FogExtensions
end

begin
  require 'fog'

  Fog::Model.send(:include, FogExtensions::Model)

  require 'fog/aws'
  require 'fog/aws/models/compute/flavor'
  Fog::Compute::AWS::Flavor.send(:include, FogExtensions::AWS::Flavor)
  require 'fog/aws/models/compute/server'
  Fog::Compute::AWS::Server.send(:include, FogExtensions::AWS::Server)

  require 'fog/libvirt'
  require 'fog/libvirt/models/compute/server'
  Fog::Compute::Libvirt::Server.send(:include, FogExtensions::Libvirt::Server)

  require 'fog/ovirt'
  require 'fog/ovirt/models/compute/server'
  Fog::Compute::Ovirt::Server.send(:include, FogExtensions::Ovirt::Server)

  require 'fog/ovirt/models/compute/volume'
  Fog::Compute::Ovirt::Volume.send(:include, FogExtensions::Ovirt::Volume)

  require 'fog/openstack'
  require 'fog/openstack/models/compute/server'
  Fog::Compute::OpenStack::Server.send(:include, FogExtensions::Openstack::Server)

  require 'fog/openstack/models/compute/flavor'
  Fog::Compute::OpenStack::Flavor.send(:include, FogExtensions::Openstack::Flavor)

  require 'fog/vsphere'
  require 'fog/vsphere/models/compute/server'
  Fog::Compute::Vsphere::Server.send(:include, FogExtensions::Vsphere::Server)

  require 'fog/vsphere/models/compute/folder'
  Fog::Compute::Vsphere::Folder.send(:include, FogExtensions::Vsphere::Folder)

rescue LoadError
  Rails.logger.info "Fog is not installed - unable to manage compute resources"
rescue => exception
  Rails.logger.warn "Fog initialization failed - #{exception}"
  Rails.logger.debug exception.backtrace.join("\n")
end
