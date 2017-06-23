module Foreman::Model
  class EC2 < ComputeResource
    include KeyPairComputeResource
    delegate :flavors, :subnets, :to => :client
    delegate :security_groups, :flavors, :zones, :to => :self, :prefix => 'available'
    validates :user, :password, :presence => true

    alias_attribute :access_key, :user
    alias_attribute :region, :url

    def to_label
      "#{name} (#{region}-#{provider_friendly_name})"
    end

    def provided_attributes
      super.merge({ :ip => :vm_ip_address })
    end

    def self.available?
      Fog::Compute.providers.include?(:aws)
    end

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:image]
    end

    def find_vm_by_uuid(uuid)
      super
    rescue Fog::Compute::AWS::Error
      raise(ActiveRecord::RecordNotFound)
    end

    def create_vm(args = { })
      args = vm_instance_defaults.merge(args.to_h.symbolize_keys).deep_symbolize_keys
      if (name = args[:name])
        args[:tags] = {:Name => name}
      end
      if (image_id = args[:image_id])
        image = images.find_by_uuid(image_id.to_s)
        iam_hash = image.iam_role.present? ? {:iam_instance_profile_name => image.iam_role} : {}
        args.merge!(iam_hash)
      end
      args[:groups].reject!(&:empty?) if args.has_key?(:groups)
      args[:security_group_ids].reject!(&:empty?) if args.has_key?(:security_group_ids)
      args[:associate_public_ip] = subnet_implies_is_vpc?(args) && args[:managed_ip] == 'public'
      args[:private_ip_address] = args[:interfaces_attributes][:"0"][:ip]
      super(args)
    rescue Fog::Errors::Error => e
      Foreman::Logging.exception("Unhandled EC2 error", e)
      raise e
    end

    def security_groups(vpc = nil)
      groups = client.security_groups
      groups.reject! { |sg| sg.vpc_id != vpc } if vpc
      groups
    end

    def regions
      return [] if user.blank? || password.blank?
      @regions ||= client.describe_regions.body["regionInfo"].map { |r| r["regionName"] }
    end

    def zones
      @zones ||= client.describe_availability_zones.body["availabilityZoneInfo"].map { |r| r["zoneName"] if r["regionName"] == region }.compact
    end

    def test_connection(options = {})
      super
      errors[:user].empty? && errors[:password].empty? && regions
    rescue Fog::Compute::AWS::Error => e
      errors[:base] << e.message
    rescue Excon::Error::Socket => e
      errors[:base] << e.message
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      vm.console_output.body.merge(:type=>'log', :name=>vm.name)
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

    def associated_host(vm)
      associate_by("ip", [vm.public_ip_address, vm.private_ip_address])
    end

    def user_data_supported?
      true
    end

    def image_exists?(image)
      client.images.get(image).present?
    end

    private

    def subnet_implies_is_vpc? args
      args[:subnet_id].present?
    end

    def client
      @client ||= ::Fog::Compute.new(:provider => "AWS", :aws_access_key_id => user, :aws_secret_access_key => password, :region => region, :connection_options => connection_options)
    end

    def vm_instance_defaults
      super.merge(
        :flavor_id => "m1.small",
        :key_pair  => key_pair
      )
    end
  end
end
