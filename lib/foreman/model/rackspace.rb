module Foreman::Model
  class Rackspace < ComputeResource

#    validates_presence_of :auth_url, :user, :api_key

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

    def find_vm_by_uuid uuid
      client.servers.get(uuid)
    rescue Fog::Compute::AWS::Error
      raise(ActiveRecord::RecordNotFound)
    end

    def create_vm args = { }
      args = vm_instance_defaults.merge(args.to_hash.symbolize_keys)

      x=vm_instance_defaults.merge(args.to_hash)
      vm = client.servers.create x 
      vm.wait_for { ready? }
      vm.setup(:password => vm.password, :auth_methods=>["password"])
      vm

    rescue Fog::Errors::Error => e
      logger.debug "Fog error: #{e.class}:#{e.message}\n " + e.backtrace.join("\n ")
      errors.add(:base, e.message.to_s)
      false
    rescue Exception =>e
      logger.debug "Unhandled Rackspace error: #{e.class}:#{e.message}\n " + e.backtrace.join("\n ")
      errors.add(:base, e.message.to_s)

      false
    end

    def security_groups
      ["default"]
    end

    def regions
      ["rackspace"]
    end

    def zones
      ["rackspace"]
    end

    def flavors
      client.flavors
    end

    def test_connection
      super
      errors[:user].empty? and errors[:password] and regions
    rescue Fog::Compute::AWS::Error => e
      errors[:base] << e.message
    end

    def region= value
    end

    def region
      "rackspace"
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

    # not supporting update at the moment
    def update_required?(old_attrs, new_attrs)
      false
    end

    def provider_friendly_name
	"rackspace"
    end

    def key_pair
      return @key_pair if @key_pair
      @key_pair = KeyPair.new :name => name, :secret => IO.read(vm_instance_defaults[:private_key_path])
    end

    private

    def client
      @client ||= ::Fog::Compute.new(:provider => "Rackspace", :rackspace_api_key => password, :rackspace_username => user, :rackspace_auth_url => url)
    end

    def vm_instance_defaults
      {
        :flavor_id => 1, #256 server
        :name      => "foreman-#{Foreman.uuid}",
        :private_key_path => File.expand_path("~/.ssh/#{name}"), 
	:public_key_path => File.expand_path("~/.ssh/#{name}.pub")
      }
    end
  end
end
