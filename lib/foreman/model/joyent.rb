module Foreman::Model
  class Joyent < ComputeResource

    validates_presence_of :user, :password

    def to_label
      "#{name} (#{region}-#{provider_friendly_name})"
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

    def datacenters
      return [] if user.blank? or password.blank?
      @datacenters ||= client.list_datacenters.body.keys.map { |r| r["datacenter"].to_s}
    end

    def test_connection
      super
      errors[:user].empty? and errors[:password] and datacenters
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
        :memory => "512",
        :name      => "foreman-#{Foreman.uuid}",
        :datacenter => "us-east-1"
      }
    end
  end
end
