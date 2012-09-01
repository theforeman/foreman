module Foreman::Model
  class Joyent < ComputeResource
    has_one :key_pair, :foreign_key => :compute_resource_id

    validates_presence_of :user, :password
    after_create :setup_key_pair
    after_destroy :destroy_key_pair

    def to_label
      "#{name} (#{region}-#{provider_friendly_name})"
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

    def find_vm_by_uuid uuid
      client.servers.get(uuid)
    rescue Fog::Compute::Joyent::Error
      raise(ActiveRecord::RecordNotFound)
    end

    def create_vm args = { }
      args = vm_instance_defaults.merge(args.to_hash.symbolize_keys)
      if (name = args[:name])
        args.merge!(:tags => {:Name => name})
      end
      super(args)
    end

    def datacenter
      return [] if user.blank? or password.blank?
      @regions ||= client.receive_datacenters.body["datacenters"].map { |r| r["datacenter"] }
    end

    def test_connection
      super
      errors[:user].empty? and errors[:password] and regions
    rescue Fog::Compute::Joyent::Error => e
      errors[:base] << e.message
    end

    def region
      @region ||= url.present? ? url : nil
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      vm.console_output.body
    end

    def destroy_vm(uuid)
      vm = find_vm_by_uuid(uuid)
      vm.destroy if vm
      true
    end

    private

    def client
      @client ||= ::Fog::Compute.new(:provider => "Joyent", :joyent_username => user, :joyent_password => password)
    end

    def vm_instance_defaults
      {
        :flavor_id => "m1.small",
        :name      => "foreman-#{Foreman.uuid}",
        :datacenter => "us-east-1"
      }
    end
  end
end
