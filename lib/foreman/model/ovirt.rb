module Foreman::Model
  class Ovirt < ComputeResource

    validates_format_of :url, :with => URI.regexp
    validates_presence_of :user, :password

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:build]
    end

    def supports_update?
      true
    end

    def provided_attributes
      super.merge({:mac => :mac})
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
      vm = super args
      begin
        create_interfaces(vm, args[:interfaces_attributes])
        create_volumes(vm, args[:volumes_attributes])
      rescue => e
        destroy_vm vm.id
        raise e
      end
      vm
    end

    def new_vm(attr={})
      vm = client.servers.new vm_instance_defaults.merge(attr)
      interfaces = nested_attributes_for :interfaces, attr[:interfaces_attributes]
      interfaces.map{ |i| vm.interfaces << new_interface(i)}
      volumes = nested_attributes_for :volumes, attr[:volumes_attributes]
      volumes.map{ |v| vm.volumes << new_volume(v)}
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

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      raise "VM is not running!" if vm.status == "down"
      if vm.display[:type] =~ /spice/i
        {:address => vm.display[:address], :secure_port => vm.display[:secure_port],:ticket => vm.ticket, :ca_cert => cacert}
      else
        VNCProxy.start(:host => vm.display[:address], :host_port => vm.display[:port], :password => vm.ticket)
      end
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

    def cacert
      ca_url = URI.parse(url)
      ca_url.path = "/ca.crt"
      ca_url.scheme = "http"
      ca_url.port = 8080 if ca_url.port == 8443
      ca_url.port = 80 if ca_url.port == 443
      Net::HTTP.get(ca_url).to_s.gsub(/\n/, '\\n')
    end

    def update_required?(old_attrs, new_attrs)
      return true if super(old_attrs, new_attrs)

      new_attrs[:interfaces_attributes].each do |key, interface|
        return true if (interface[:id].blank? || interface[:_delete] == '1') && key != 'new_interfaces' #ignore the template
      end if new_attrs[:interfaces_attributes]

      new_attrs[:volumes_attributes].each do |key, volume|
        return true if (volume[:id].blank? || volume[:_delete] == '1') && key != 'new_volumes' #ignore the template
      end if new_attrs[:volumes_attributes]

      false
    end


    private
    def create_interfaces(vm, attrs)
      #first remove all existing interfaces
      vm.interfaces.each do |interface|
        #The blocking true is a work-around for ovirt bug, it should be removed.
        vm.destroy_interface(:id => interface.id, :blocking => true)
      end if vm.interfaces
      #add interfaces
      interfaces = nested_attributes_for :interfaces, attrs
      interfaces.map{ |i| vm.add_interface(i)}
      vm.interfaces.reload
    end

    def create_volumes(vm, attrs)
      #add volumes
      volumes = nested_attributes_for :volumes, attrs
      #The blocking true is a work-around for ovirt bug, it should be removed.
      volumes.map{ |vol| vm.add_volume({:bootable => 'false',:blocking => true}.merge(vol)) if vol[:id].blank?}
      vm.volumes.reload
    end

    def update_interfaces(vm, attrs)
      interfaces = nested_attributes_for :interfaces, attrs
      interfaces.each do |interface|
          vm.destroy_interface(:id => interface[:id]) if interface[:_delete] == '1' && interface[:id]
          vm.add_interface(interface) if interface[:id].blank?
      end
    end

    def update_volumes(vm, attrs)
      volumes = nested_attributes_for :volumes, attrs
      volumes.each do |volume|
        vm.destroy_volume(:id => volume[:id], :blocking => true) if volume[:_delete] == '1' && volume[:id].present?
        vm.add_volume({:bootable => 'false',:blocking => true}.merge(volume)) if volume[:id].blank?
      end
    end

  end
end
