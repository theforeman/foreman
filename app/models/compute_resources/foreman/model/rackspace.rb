module Foreman::Model
  class Rackspace < ComputeResource
    validates :url, :format => { :with => URI::DEFAULT_PARSER.make_regexp }, :presence => true
    validates :user, :password, :region, :presence => true
    validate :ensure_valid_region

    delegate :flavors, :to => :client

    def provided_attributes
      super.merge(:ip => :ipv4_address, :ip6 => :ipv6_address)
    end

    def self.available?
      Fog::Compute.providers.include?(:rackspace)
    end

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:image]
    end

    def find_vm_by_uuid(uuid)
      super
    rescue Fog::Compute::Rackspace::Error
      raise(ActiveRecord::RecordNotFound)
    end

    def create_vm(args = { })
      super(args)
    rescue Fog::Errors::Error => e
      Foreman::Logging.exception("Unhandled Rackspace error", e)
      raise e
    end

    def security_groups
      ["default"]
    end

    def regions
      ['IAD', 'ORD', 'DFW', 'LON', 'SYD', 'HKG']
    end

    def zones
      ["rackspace"]
    end

    def available_images
      client.images
    end

    def test_connection(options = {})
      super && flavors
    rescue Excon::Errors::Unauthorized => e
      errors[:base] << e.response.body
    rescue Fog::Compute::Rackspace::Error, Excon::Errors::SocketError => e
      errors[:base] << e.message
    end

    def region=(value)
      self.uuid = value
    end

    def region
      uuid
    end

    def destroy_vm(uuid)
      vm = find_vm_by_uuid(uuid)
      vm&.destroy
      true
    end

    # not supporting update at the moment
    def update_required?(old_attrs, new_attrs)
      false
    end

    def self.provider_friendly_name
      "Rackspace"
    end

    def ensure_valid_region
      errors.add(:region, 'is not valid') unless regions.include?(region.to_s.upcase)
    end

    def associated_host(vm)
      associate_by("ip", [vm.public_ip_address, vm.private_ip_address])
    end

    def user_data_supported?
      true
    end

    def normalize_vm_attrs(vm_attrs)
      normalized = slice_vm_attributes(vm_attrs, ['flavor_id', 'image_id'])

      normalized['flavor_name'] = self.flavors.detect { |f| f.id == normalized['flavor_id'] }.try(:name)
      normalized['image_name'] = self.images.find_by(:uuid => normalized['image_id']).try(:name)
      normalized
    end

    private

    def client
      @client ||= Fog::Compute.new(
        :provider => "Rackspace",
        :version => 'v2',
        :rackspace_api_key => password,
        :rackspace_username => user,
        :rackspace_auth_url => url,
        :rackspace_region => region.downcase.to_sym
      )
    end

    def vm_instance_defaults
      # 256 server
      super.merge(
        :flavor_id => 1,
        :config_drive => true
      )
    end
  end
end
