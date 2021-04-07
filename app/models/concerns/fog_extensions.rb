module FogExtensions
end

require 'concerns/fog_extensions/model'
Fog::Model.include FogExtensions::Model if defined? Fog::Model

# Fog is required by bundler, and depending on the group configuration,
# different providers will be available.
if Foreman::Model::EC2.available?
  require 'fog/aws'
  require 'fog/aws/models/compute/flavor'
  Fog::AWS::Compute::Flavor.include FogExtensions::AWS::Flavor
  require 'fog/aws/models/compute/server'
  Fog::AWS::Compute::Server.include FogExtensions::AWS::Server
  require 'fog/aws/models/iam/instance_profile'
  Fog::AWS::IAM::InstanceProfile.include FogExtensions::AWS::IAM::InstanceProfile
end

if Foreman::Model::GCE.available?
  require 'fog/google'
  require 'fog/compute/google/models/machine_type'
  Fog::Compute::Google::MachineType.prepend FogExtensions::Google::MachineType
  require 'fog/compute/google/models/server'
  Fog::Compute::Google::Server.include FogExtensions::Google::Server
end

if Foreman::Model::Libvirt.available?
  require 'fog/libvirt'
  require 'fog/libvirt/compute'
  require 'fog/libvirt/models/compute/server'
  Fog::Libvirt::Compute::Server.include FogExtensions::Libvirt::Server
end

if Foreman::Model::Ovirt.available?
  require 'fog/ovirt'
  require 'fog/ovirt/models/compute/server'
  Fog::Ovirt::Compute::Server.include FogExtensions::Ovirt::Server
  require 'fog/ovirt/models/compute/template'
  Fog::Ovirt::Compute::Template.include FogExtensions::Ovirt::Template

  require 'fog/ovirt/models/compute/volume'
  Fog::Ovirt::Compute::Volume.include FogExtensions::Ovirt::Volume
end

if Foreman::Model::Openstack.available?
  require 'fog/openstack'
  require 'fog/openstack/compute/models/server'
  require 'fog/openstack/compute/models/flavor'
  Fog::OpenStack::Compute::Real.include FogExtensions::Openstack::Core
  Fog::OpenStack::Compute::Server.prepend FogExtensions::Openstack::Server
  Fog::OpenStack::Compute::Flavor.include FogExtensions::Openstack::Flavor
end

if Foreman::Model::Vmware.available?
  require 'fog/vsphere'
  require 'fog/vsphere/models/compute/cluster'
  require 'fog/vsphere/models/compute/network'
  require 'fog/vsphere/models/compute/server'
  Fog::Vsphere::Compute::Server.include FogExtensions::Vsphere::Server

  require 'fog/vsphere/models/compute/folder'
  Fog::Vsphere::Compute::Folder.include FogExtensions::Vsphere::Folder
end
