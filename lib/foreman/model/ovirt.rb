module Foreman::Model
  class Ovirt < ComputeResource

    validates_format_of :url, :with => URI.regexp
    validates_presence_of :user, :password

    def self.model_name
      ComputeResource.model_name
    end

    #FIXME
    def max_cpu_count
      8
    end

    def max_memory
      16*1024*1024*1024
    end

    def hardware_profiles(opts={})
      client.templates
    end

    def hardware_profile(id)
      client.templates.get(id) || raise(ActiveRecord::RecordNotFound)
    end

    def clusters
      client.clusters
    end

    def test_connection
      super
      errors[:url].empty? && datacenters
    rescue => e
      case e.message
        when /404/
          errors[:url] << e.message
        when /401/
          errors[:user] << e.message
        else
          errors[:base] << e.message
      end
    end

    def datacenters(options={})
      client.datacenters(options).map { |dc| [dc[:name], dc[:id]] }
    end

    def networks(opts ={})
      if opts[:cluster_id]
        client.clusters.get(opts[:cluster_id]).networks
      else
        []
      end

    end

    def storage_domains(opts ={})
      client.storage_domains({:role => 'data'}.merge(opts))
    end

    def start_vm(uuid)
      find_vm_by_uuid(uuid).start(:blocking => true)
    end

    def create_vm(args = {})
      #ovirt doesn't accept '.' in vm name.
      args[:name] = args[:name].parameterize
      args[:display] = 'VNC'
      vm          = super args
      begin
        set_interfaces(vm, args[:interfaces_attributes])
        add_volumes(vm, args[:volumes_attributes])
      rescue => e
        destroy_vm vm.id
        raise e
      end
      vm
    end

    def new_vm(attr={})
      vm = client.servers.new vm_instance_defaults.merge(attr)
      attr[:interfaces_attributes].each do |key, interface|
        vm.interfaces << new_interface(interface) unless (interface[:_delete] =='1' && interface[:id].nil?) || key == 'new_interfaces' #ignore the template
      end if attr[:interfaces_attributes]

      attr[:volumes_attributes].each do |key, volume|
        vm.volumes << new_volume(volume) unless (volume[:_delete] =='1' && volume[:id].nil?) || key == 'new_volumes' #ignore the template
      end if attr[:volumes_attributes]
      vm
    end

    def new_interface(attr={})
      Fog::Compute::Ovirt::Interface.new(attr)
    end

    def new_volume(attr={})
      Fog::Compute::Ovirt::Volume.new(attr)
    end

    def save_vm(uuid, attr)
      vm = find_vm_by_uuid(uuid)
      vm.attributes.merge!(attr.symbolize_keys)
      update_interfaces(vm, attr[:interfaces_attributes])
      update_volumes(vm, attr[:volumes_attributes])
      vm.interfaces
      vm.volumes
      vm.save
    end

    def destroy_vm(uuid)
      begin
        find_vm_by_uuid(uuid).destroy
      rescue OVIRT::OvirtException => e
        #404 error are ignored on delete.
        raise e unless e.message =~ /404/
      end
      true
    end

    protected

    def bootstrap(args)
      client.servers.bootstrap vm_instance_defaults.merge(args.to_hash)
    rescue Fog::Errors::Error => e
      errors.add(:base, e.to_s)
      false
    end


    def client
      @client ||= ::Fog::Compute.new(
          :provider         => "ovirt",
          :ovirt_username   => user,
          :ovirt_password   => password,
          :ovirt_url        => url,
          :ovirt_datacenter => uuid
      )
    end

    def update_required?(old_attrs, new_attrs)
      return true if super(old_attrs, new_attrs)

      new_attrs[:interfaces_attributes].each do |key, interface|
        return true if (interface[:id].nil? || interface[:_delete] == '1') && key != 'new_interfaces' #ignore the template
      end if new_attrs[:interfaces_attributes]

      new_attrs[:volumes_attributes].each do |key, volume|
        return true if (volume[:id].nil? || volume[:_delete] == '1') && key != 'new_volumes' #ignore the template
      end if new_attrs[:volumes_attributes]

      false
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      raise "VM is not running!" if vm.status == "down"
      raise "Spice display is not supported at the moment" if vm.display[:type] =~ /spice/i
      VNCProxy.start(:host => vm.display[:address], :host_port => vm.display[:port], :password => vm.ticket)
    end

    private
    def set_interfaces(vm, attrs)
      #first remove all existing interfaces
      vm.interfaces.each do |interface|
        #The blocking true is a work-around for ovirt bug, it should be removed.
        vm.destroy_interface(:id => interface.id, :blocking => true)
      end if vm.interfaces
      #add interfaces
      attrs.each do |key, interface|
        vm.add_interface(interface) if interface[:id].nil? && interface[:_delete] != '1' && key != 'new_interfaces'
      end if attrs
      vm.interfaces.reload
    end

    def add_volumes(vm, attrs)
      #add volumes
      attrs.each do |key, volume|
        vm.add_volume(volume.merge(:blocking => true)) if volume[:storage_domain] && volume[:_delete] != '1' && key != 'new_volumes'
      end if attrs
      vm.volumes.reload
    end

    def update_interfaces(vm, attrs)
      attrs.each do |key, interface|
        unless key == 'new_interfaces' #ignore the template
          vm.destroy_interface(:id => interface[:id]) if interface[:_delete] == '1' && interface[:id]
          vm.add_interface(interface) if interface[:id].nil?
        end
      end if attrs
    end

    def update_volumes(vm, attrs)
      attrs.each do |key, volume|
        unless key == 'new_volumes' #ignore the template
          vm.destroy_volume(:id => volume[:id]) if volume[:_delete] == '1' && volume[:id]
          vm.add_volume(volume) if volume[:id].nil?
        end
      end if attrs
    end

  end
end
