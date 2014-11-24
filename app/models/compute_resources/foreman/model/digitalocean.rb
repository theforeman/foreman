module Foreman::Model
  class Digitalocean < ComputeResource
    has_one :key_pair, :foreign_key => :compute_resource_id, :dependent => :destroy
    delegate :flavors, :to => :client
    delegate :regions, :to => :client

    validates :user, :password, :presence => true

    # Not sure why it would need a url, but OK (copied from ec2)
    alias_attribute :region, :url

    def to_label
      "#{name} (#{provider_friendly_name})"
    end

    def provided_attributes
      super.merge({ :ip => :public_ip_address })
    end

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:image]
    end

    def find_vm_by_uuid(uuid)
      client.servers.get(uuid)
    rescue Fog::Compute::DigitalOcean::Error
      raise(ActiveRecord::RecordNotFound)
    end

    def create_vm(args = { })
      super(args)
    rescue Fog::Errors::Error => e
      logger.error "Unhandled DigitalOcean error: #{e.class}:#{e.message}\n " + e.backtrace.join("\n ")
      raise e
    end

    def available_images
      client.images
    end

    def test_connection(options = {})
      super
      errors[:user].empty? and errors[:password].empty? and regions
    rescue Excon::Errors::Unauthorized => e
      errors[:base] << e.response.body
    rescue Fog::Compute::DigitalOcean::Error => e
      errors[:base] << e.message
    end

    def destroy_vm(uuid)
      vm = find_vm_by_uuid(uuid)
      vm.destroy if vm
      true
    end

    # not supporting update at the moment
    def update_required?(old_attrs, new_attrs)
      false
    end

    def self.provider_friendly_name
      "Digital Ocean"
    end

    def associated_host(vm)
      Host.authorized(:view_hosts, Host).where(:ip => [vm.public_ip_address, vm.private_ip_address]).first
    end

    def user_data_supported?
      true
    end

    def default_region_name
      @default_region_name ||= client.regions.get(region.to_i).try(:name)
    end

    private

    def client
      @client ||= Fog::Compute.new(
        :provider => "DigitalOcean",
        :digitalocean_client_id => user,
        :digitalocean_api_key => password,
      )
    end

    def vm_instance_defaults
      super.merge(
        :flavor_id => client.flavors.first.id
      )
    end

  end
end
