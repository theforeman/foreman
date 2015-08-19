module FogExtensions
end

Fog::Model.send(:include, FogExtensions::Model) if defined? Fog::Model

# Fog is required by bundler, and depending on the group configuration,
# different providers will be available - determined in config/application.rb
# and noted in SETTINGS.
if SETTINGS[:ec2]
  require 'fog/aws'
  require 'fog/aws/models/compute/flavor'
  Fog::Compute::AWS::Flavor.send(:include, FogExtensions::AWS::Flavor)
  require 'fog/aws/models/compute/server'
  Fog::Compute::AWS::Server.send(:include, FogExtensions::AWS::Server)
end

if SETTINGS[:gce]
  require 'fog/google'
  require 'fog/google/models/compute/image'
  Fog::Compute::Google::Image.send(:include, FogExtensions::Google::Image)
  require 'fog/google/models/compute/server'
  Fog::Compute::Google::Server.send(:include, FogExtensions::Google::Server)
  require 'fog/google/models/compute/flavor'
  Fog::Compute::Google::Flavor.send(:include, FogExtensions::Google::Flavor)
end

if SETTINGS[:libvirt]
  require 'fog/libvirt'
  require 'fog/libvirt/compute'
  require 'fog/libvirt/models/compute/server'
  Fog::Compute::Libvirt::Server.send(:include, FogExtensions::Libvirt::Server)
end

if SETTINGS[:ovirt]
  require 'fog/ovirt'
  require 'fog/ovirt/models/compute/server'
  Fog::Compute::Ovirt::Server.send(:include, FogExtensions::Ovirt::Server)
  require 'fog/ovirt/models/compute/template'
  Fog::Compute::Ovirt::Template.send(:include, FogExtensions::Ovirt::Template)

  require 'fog/ovirt/models/compute/volume'
  Fog::Compute::Ovirt::Volume.send(:include, FogExtensions::Ovirt::Volume)
end

if SETTINGS[:openstack]
  require 'fog/openstack'
  require 'fog/openstack/models/compute/server'
  Fog::Compute::OpenStack::Server.send(:include, FogExtensions::Openstack::Server)

  require 'fog/openstack/models/compute/flavor'
  Fog::Compute::OpenStack::Flavor.send(:include, FogExtensions::Openstack::Flavor)
end

if SETTINGS[:vmware]
  require 'fog/vsphere'
  require 'fog/vsphere/models/compute/server'
  Fog::Compute::Vsphere::Server.send(:include, FogExtensions::Vsphere::Server)

  require 'fog/vsphere/models/compute/folder'
  Fog::Compute::Vsphere::Folder.send(:include, FogExtensions::Vsphere::Folder)
end

if SETTINGS[:rackspace]
  require 'fog/rackspace'
  require 'fog/rackspace/models/compute_v2/server'
  Fog::Compute::RackspaceV2::Server.send(:include, FogExtensions::RackspaceV2::Server)
end
