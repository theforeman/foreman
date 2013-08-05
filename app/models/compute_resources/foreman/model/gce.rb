module Foreman::Model
  class GCE < ComputeResource
    has_one :key_pair, :foreign_key => :compute_resource_id
    after_create :setup_key_pair
    after_destroy :destroy_key_pair

    def capabilities
	[:image]
    end

    def provided_attributes
        super.merge({ :ip => :private_ip_address })
    end

    def zones
	 client.list_zones.body['items'].map{ |zone| zone['name'] }
    end

    def networks
	 client.list_networks.body['items'].map{|n| n['name']}
    end

    def flavors
      client.flavors
    end

    def vms
      client.servers
    end

    def create_vm args = {}
      #Dot are not allowed in names
      args['name'] = args['name'].split('.').first
      args['image_name'] = args['image_id']
      if args['external_ip'] == '0'
        args['external_ip']=false
      else
        args['external_ip']=true
      end
      ssh = { :user => self.images.first.username, :public_key => self.key_pair.public }
      args.merge! ssh
      vm = super(args)
      rescue Exception => e
        logger.debug "Unhandled GCE error: #{e.class}:#{e.message}\n " + e.backtrace.join("\n ")
        errors.add(:base, e.message.to_s)
        false
    end

    def available_images
       images = client.images
    end 

    def self.model_name
	    ComputeResource.model_name
    end

    def setup_key_pair
      require 'sshkey'
      name = "foreman-#{id}#{Foreman.uuid}"
      key = ::SSHKey.generate
      KeyPair.create! :name => name, :compute_resource_id => self.id, :secret => key.private_key, :public => key.ssh_public_key
    end

    def destroy_key_pair
      key_pair = KeyPair.find_by_compute_resource_id(self.id)
      key_pair.destroy
    end


     private
     def client
        @client ||= ::Fog::Compute.new(:provider => 'google', :google_project => user, :google_client_email => password, :google_key_location => url)
     end
  end
end
