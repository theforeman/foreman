require 'opennebula'

module Foreman::Model
  class One < ComputeResource
    has_one :key_pair, :foreign_key => :compute_resource_id, :dependent => :destroy

    validates :user, :password, :presence => true
    validates :url, :format => { :with => URI.regexp }

    def provider_friendly_name
      "OpenNebula"
    end

    def provided_attributes
      super.merge({ :mac => :vm_mac_address })
    end

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:build]
    end

    def find_vm_by_uuid uuid
      client.servers.get(uuid)
    rescue Fog::Compute::AWS::Error
      raise(ActiveRecord::RecordNotFound)
    end

    def new_vm attr={ }
      client.servers.new vm_instance_defaults.merge(attr.to_hash.symbolize_keys) if errors.empty?
    end

    def interfaces
      #client.interfaces rescue []
      []
    end

    def networks
      client.networks rescue []
    end
 

    def flavors
      client.flavors
    end

    def groups
      client.groups
    end

    def create_vm args = { }
      args = vm_instance_defaults.merge(args.to_hash.symbolize_keys)
      logger.info "CREATEVM ARGS #{args.inspect}"
      #ARGS: {"name"=>"aaa.example.com", "b0e"=>"foob0e", "foob0e"=>"b0e", "template_id"=>"4", "vcpu"=>"", "memory"=>"", "interfaces_attributes"=>{"new_interfaces"=>{"id"=>"0", "_delete"=>"", "model"=>"virtio"}, "new_1398239695352"=>{"id"=>"2", "_delete"=>"", "model"=>"virtio"}, "new_1398239700415"=>{"id"=>"2", "_delete"=>"", "model"=>"virtio"}, "new_1398239705632"=>{"id"=>"0", "_delete"=>"", "model"=>"e1000"}}}

      vm = client.servers.new
      vm.name = args[:name]
      vm.gid = args[:gid] unless args[:gid].empty?
      vm.flavor = client.flavors.get(args[:template_id])

      vm.flavor.VCPU = args[:vcpu] unless args[:vcpu].empty?
      vm.flavor.MEMORY = args[:memory] unless args[:memory].empty?
      vm.flavor.NIC = []

      #INTERFACES {"new_interfaces"=>{"id"=>"0", "_delete"=>"", "model"=>"virtio"}, "new_1398239695352"=>{"id"=>"2", "_delete"=>"", "model"=>"virtio"}, "new_1398239700415"=>{"id"=>"2", "_delete"=>"", "model"=>"virtio"}, "new_1398239705632"=>{"id"=>"0", "_delete"=>"", "model"=>"e1000"}}
      logger.info "INTERFACES #{args[:interfaces_attributes].inspect}"
      nics = args[:interfaces_attributes].values
      if nics.is_a? Array then
        nics.each do |nic|
	  unless (nic["id"].empty? || nic["model"].empty?)
	    vm.flavor.NIC << client.interfaces.new({ :vnet => client.networks.get(nic["id"]), :model => nic["model"]})
	  end
        end
      end

      logger.info "VM: #{vm.inspect}"
      logger.info "FLAVOR: #{vm.flavor.inspect}"
      logger.info "NIC: #{vm.flavor.NIC.inspect}"
      logger.info "FLAVORtos: #{vm.flavor.to_s}"
      vm.save
    end

    def test_connection options = {}
      super
      errors[:user].empty? and errors[:password].empty? and not client.client.get_version.is_a?(OpenNebula::Error)
    rescue Fog::Compute::AWS::Error => e
      errors[:base] << e.message
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      vm.console_output.body.merge(:type=>'vnc', :name=>vm.name)
    end

    def destroy_vm(uuid)
      vm = find_vm_by_uuid(uuid)
      vm.destroy if vm
      true
    end

    def start_vm(uuid)
      #vm = find_vm_by_uuid(uuid)
      #logger.info "VM DESTROY: #{vm.class} #{vm.methods}"
      #vm.destroy if vm
      true
    end

    # not supporting update at the moment
    def update_required?(old_attrs, new_attrs)
      false
    end

#    def associated_host(vm)
#      Host.my_hosts.where(:ip => [vm.public_ip_address, vm.private_ip_address]).first
#    end

    def associated_host(vm)
      Host.my_hosts.where(:mac => [vm.vm_mac_address]).first
    end

    def new_interface attr={ }
      client.interfaces.new attr
    end

    private

    def client
      @client ||= Fog::Compute.new({:provider => 'OpenNebula', :opennebula_username => user, :opennebula_password => password, :opennebula_endpoint => url})
    end


    def vm_instance_defaults
      super.merge(
        :b0e => "foob0e",
        :foob0e  => "b0e"
      )
    end

  end
end
