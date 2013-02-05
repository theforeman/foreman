module Foreman::Model
  class Rackspace < ComputeResource

    validates_presence_of :user, :password, :region

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
    rescue Fog::Compute::Rackspace::Error
      raise(ActiveRecord::RecordNotFound)
    end

    def create_vm args = { }
      super(args)
    rescue Exception => e
      logger.debug "Unhandled Rackspace error: #{e.class}:#{e.message}\n " + e.backtrace.join("\n ")
      errors.add(:base, e.message.to_s)
      false
    end

    def security_groups
      ["default"]
    end

    def regions
      ['ORD', 'DFW', 'LON']
    end

    def endpoint
      case region
        when 'DFW'
          'https://dfw.servers.api.rackspacecloud.com/v2'
        when 'LON'
          'https://lon.servers.api.rackspacecloud.com/v2'
        else
          'https://ord.servers.api.rackspacecloud.com/v2'
      end
    end

    def zones
      ["rackspace"]
    end

    def flavors
      client.flavors
    end

    def available_images
      client.images
    end

    def test_connection
      super and flavors
    rescue Excon::Errors::Unauthorized => e
      errors[:base] << e.response.body
    rescue Fog::Compute::Rackspace::Error => e
      errors[:base] << e.message
    end

    def region= value
      self.uuid = value
    end

    def region
      uuid
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
      "Rackspace"
    end

    private

    def client
      @client = Fog::Compute.new(:provider => "Rackspace", :version => 'v2', :rackspace_api_key => password, :rackspace_username => user, :rackspace_auth_url => url, :rackspace_endpoint => endpoint)
      return @client
    end

    def vm_instance_defaults
      {
        :flavor_id => 1, #256 server
        :name      => "foreman-#{Foreman.uuid}",
      }
    end
  end
end
