module Foreman::Model
  class EC2 < ComputeResource
    has_one :key_pair, :foreign_key => :compute_resource_id, :dependent => :destroy

    delegate :subnets, :to => :client
    validates :user, :password, :presence => true

    after_create :setup_key_pair
    after_destroy :destroy_key_pair

    alias_attribute :access_key, :user
    alias_attribute :region, :url

    def to_label
      "#{name} (#{region}-#{provider_friendly_name})"
    end

    def provided_attributes
      super.merge({ :ip => :vm_ip_address })
    end

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:image]
    end

    def find_vm_by_uuid(uuid)
      client.servers.get(uuid)
    rescue Fog::Compute::AWS::Error
      raise(ActiveRecord::RecordNotFound)
    end

    def create_vm(args = { })
      args = vm_instance_defaults.merge(args.to_hash.symbolize_keys).deep_symbolize_keys
      if (name = args[:name])
        args.merge!(:tags => {:Name => name})
      end
      if (image_id = args[:image_id])
        image = images.find_by_uuid(image_id)
        iam_hash = image.iam_role.present? ? {:iam_instance_profile_name => image.iam_role} : {}
        args.merge!(iam_hash)
      end
      args[:groups].reject!(&:empty?) if args.has_key?(:groups)
      args[:security_group_ids].reject!(&:empty?) if args.has_key?(:security_group_ids)
      args[:associate_public_ip] = subnet_implies_is_vpc?(args) && args[:managed_ip] == 'public'
      super(args)
    rescue Fog::Errors::Error => e
      logger.error "Unhandled EC2 error: #{e.class}:#{e.message}\n " + e.backtrace.join("\n ")
      raise e
    end

    def security_groups(vpc = nil)
      groups = client.security_groups
      groups.reject! { |sg| sg.vpc_id != vpc } if vpc
      groups
    end

    def regions
      return [] if user.blank? or password.blank?
      @regions ||= client.describe_regions.body["regionInfo"].map { |r| r["regionName"] }
    end

    def zones
      @zones ||= client.describe_availability_zones.body["availabilityZoneInfo"].map { |r| r["zoneName"] if r["regionName"] == region }.compact
    end

    def flavors
      client.flavors
    end

    def test_connection(options = {})
      super
      errors[:user].empty? and errors[:password].empty? and regions
    rescue Fog::Compute::AWS::Error => e
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
      @client ||= ::Fog::Compute.new(:provider => "AWS", :aws_access_key_id => user, :aws_secret_access_key => password, :region => region)
    end

    # this method creates a new key pair for each new ec2 compute resource
    # it should create the key and upload it to AWS
    def setup_key_pair
      key = client.key_pairs.create :name => "foreman-#{id}#{Foreman.uuid}"
      KeyPair.create! :name => key.name, :compute_resource_id => self.id, :secret => key.private_key
    rescue => e
      logger.warn "failed to generate key pair"
      logger.error e.message
      logger.error e.backtrace.join("\n")
      destroy_key_pair
      raise
    end

    def destroy_key_pair
      return unless key_pair
      logger.info "removing AWS key #{key_pair.name}"
      key = client.key_pairs.get(key_pair.name)
      key.destroy if key
      key_pair.destroy
      true
    rescue => e
      logger.warn "failed to delete key pair from AWS, you might need to cleanup manually : #{e}"
    end

    def vm_instance_defaults
      super.merge(
        :flavor_id => "m1.small",
        :key_pair  => key_pair
      )
    end
  end
end
