module Foreman::Model
  class Rackspace < ComputeResource
   
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
    rescue Fog::Compute::Rackspace::Error
      raise(ActiveRecord::RecordNotFound)
    end

    def create_vm args = { }
      args = vm_instance_defaults.merge(args.to_hash.symbolize_keys)

      x=vm_instance_defaults.merge(args.to_hash)
      vm = client.servers.create x 
      vm.wait_for { ready? and not vm.public_ip_address.nil?}
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
      ['ORD','DFW','LON']
    end
  
    def endpoint region
	endpoint = case region
	  when 'ORD' then
		'https://ord.servers.api.rackspacecloud.com/v2'
	  when 'DFW' then
		'https://dfw.servers.api.rackspacecloud.com/v2'
	  when 'LON' then
		'https://lon.servers.api.rackspacecloud.com/v2'
	  else 'https://ord.servers.api.rackspacecloud.com/v2'
    	end
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
       self.uuid = value
    end

    def region
	uuid
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
	"Rackspace"
    end

    private

    def client
	    @client = Fog::Compute.new(:provider => "Rackspace", :version => 'v2', :rackspace_api_key => password, :rackspace_username => user, :rackspace_auth_url => url, :rackspace_endpoint => endpoint(region))
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
