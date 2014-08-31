module Foreman::Model
  class GCE < ComputeResource
    has_one :key_pair, :foreign_key => :compute_resource_id, :dependent => :destroy
    before_create :setup_key_pair
    validate :check_google_key_path
    validates :key_path, :project, :email, :presence => true

    delegate :flavors, :to => :client

    def to_label
      "#{name} (#{zone}-#{provider_friendly_name})"
    end

    def capabilities
      [:image]
    end

    def project
      attrs[:project]
    end

    def project=(name)
      attrs[:project] = name
    end

    def key_path
      attrs[:key_path]
    end

    def key_path=(name)
      attrs[:key_path] = name
    end

    def email
      attrs[:email]
    end

    def email=(email)
      attrs[:email] = email
    end

    #TODO: allow to select public / private ip address that foreman tries to find
    def provided_attributes
      super.merge({ :ip => :public_ip_address })
    end

    def zones
      client.list_zones.body['items'].map { |zone| zone['name'] }
    end

    def networks
      client.list_networks.body['items'].map { |n| n['name'] }
    end

    def zone
      url
    end

    def zone=(zone)
      self.url = zone
    end

    def create_vm args = {}
      #Dot are not allowed in names
      args[:name]        = args[:name].parameterize if args[:name].present?
      args[:external_ip] = args[:external_ip] != '0'
      args[:image_name]  = args[:image_id]

      username = images.where(:uuid => args[:image_name]).first.try(:username)
      ssh      = { :username => username, :public_key => key_pair.public }
      super(args.merge(ssh))
    rescue Fog::Errors::Error => e
      logger.debug "Unhandled GCE error: #{e.class}:#{e.message}\n " + e.backtrace.join("\n ")
      raise e
    end

    def available_images
      client.images
    end

    def self.model_name
      ComputeResource.model_name
    end

    def setup_key_pair
      require 'sshkey'
      name = "foreman-#{id}#{Foreman.uuid}"
      key  = ::SSHKey.generate
      build_key_pair :name => name, :secret => key.private_key, :public => key.ssh_public_key
    end

    def test_connection(options = {})
      super
      errors[:user].empty? and errors[:password].empty? and zones
    rescue => e
      errors[:base] << e.message
    end

    def self.provider_friendly_name
      "Google"
    end

    private
    def client
      @client ||= ::Fog::Compute.new(:provider => 'google', :google_project => project, :google_client_email => email, :google_key_location => key_path)
    end

    def check_google_key_path
      return if key_path.blank?
      unless File.exist?(key_path)
        errors.add(:key_path, _('Unable to access key'))
      end
    rescue => e
      logger.warn("failed to access gce key path: #{e}")
      logger.debug(e.backtrace)
      errors.add(:key_path, e.message.to_s)
    end

    def vm_instance_defaults
      super.merge(
        :zone_name => zone,
        :name      => "foreman-#{Time.now.to_i}"
      )
    end
  end
end
