module Foreman::Model
  class Openstack < ComputeResource
    attr_accessor :tenant
    has_one :key_pair, :foreign_key => :compute_resource_id, :dependent => :destroy
    after_create :setup_key_pair
    after_destroy :destroy_key_pair
    delegate :flavors, :to => :client
    delegate :tenants, :to => :client
    delegate :security_groups, :to => :client

    validates_presence_of :user, :password

    def provided_attributes
      super.merge({ :ip => :floating_ip_address })
    end

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:image]
    end

    def test_connection options = {}
      super
      errors[:user].empty? and errors[:password] and tenants
    rescue => e
      errors[:base] << e.message
    end

    def available_images
      client.images
    end

    def address_pools
      client.addresses.get_address_pools.map { |p| p["name"] }
    end

    def create_vm(args = {})
      network = args.delete(:network)
      vm      = super(args)
      if network.present?
        address = allocate_address(network)
        assign_floating_ip(address, vm)
      end
      vm
    rescue => e
      message = JSON.parse(e.response.body)['badRequest']['message'] rescue (e.to_s)
      logger.warn "failed to create vm: #{message}"
      destroy_vm vm.id if vm
      raise message
    end

    def destroy_vm uuid
      vm           = find_vm_by_uuid(uuid)
      floating_ips = vm.all_addresses
      floating_ips.each do |address|
        client.disassociate_address(uuid, address['ip'])
        client.release_address(address['id'])
      end
      super(uuid)
    rescue ActiveRecord::RecordNotFound
      # if the VM does not exists, we don't really care.
      true
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      vm.console.body.merge({'timestamp' => Time.now.utc})
    end

    private

    def client
      @client ||= ::Fog::Compute.new(:provider => :openstack, :openstack_api_key => password, :openstack_username => user, :openstack_auth_url => url)
    end

    def setup_key_pair
      key = client.key_pairs.create :name => "foreman-#{id}#{Foreman.uuid}"
      KeyPair.create! :name => key.name, :compute_resource_id => self.id, :secret => key.private_key
    rescue => e
      logger.warn "failed to generate key pair"
      destroy_key_pair
      raise
    end

    def destroy_key_pair
      return unless key_pair
      logger.info "removing OpenStack key #{key_pair.name}"
      key = client.key_pairs.get(key_pair.name)
      key.destroy if key
      key_pair.destroy
      true
    rescue => e
      logger.warn "failed to delete key pair from OpenStack, you might need to cleanup manually : #{e}"
    end

    def vm_instance_defaults
      {
        :name      => "foreman-#{Foreman.uuid}",
        :key_name  => key_pair.name,
      }
    end

    def assign_floating_ip(address, vm)
      return unless address.status == 200

      # we can't assign floating IP's before we get a private IP.
      vm.wait_for { !addresses.empty? }
      floating_ip = address.body["floating_ip"]["ip"].to_s
      logger.debug("assigning #{floating_ip} to #{vm.name}")
      begin
        vm.associate_address(floating_ip)
      rescue => e
        logger.warn "failed to assign #{floating_ip} to #{vm.name}: #{e}"
        client.disassociate_address(floating_ip)
      end
    end

    def allocate_address(network)
      logger.debug "requesting floating ip address for #{network}"
      client.allocate_address(network)
    rescue => e
      logger.warn "failed to allocate ip address for network #{network}: #{e}"
      raise e
    end

  end
end
