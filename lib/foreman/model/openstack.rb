module Foreman::Model
  class Openstack < ComputeResource
    attr_accessor :tenant
    has_one :key_pair, :foreign_key => :compute_resource_id
    after_create :setup_key_pair
    after_destroy :destroy_key_pair
    delegate :flavors, :to => :client
    delegate :tenants, :to => :client
    delegate :security_groups, :to => :client

    validates_presence_of :user, :password

    def provided_attributes
      super.merge({ :ip => :public_ip_address })
    end

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:image]
    end

    def test_connection
      super
      errors[:user].empty? and errors[:password] and tenants
    rescue => e
      errors[:base] << e.message
    end

    def available_images
      client.images
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
  end
end
