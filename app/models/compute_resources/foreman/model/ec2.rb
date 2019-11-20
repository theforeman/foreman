module Foreman::Model
  class EC2 < ComputeResource
    GOV_CLOUD_REGION = 'us-gov-west-1'

    include KeyPairComputeResource
    delegate :flavors, :subnets, :to => :client
    validates :user, :password, :presence => true

    alias_attribute :access_key, :user
    alias_attribute :region, :url

    alias_method :available_flavors, :flavors

    def to_label
      "#{name} (#{region}-#{provider_friendly_name})"
    end

    def gov_cloud=(enable_gov_cloud)
      if enable_gov_cloud == '1'
        self.url ||= GOV_CLOUD_REGION
      elsif gov_cloud?
        self.url = nil
      end
    end

    def gov_cloud
      ['us-gov-west-1', 'us-gov-east-1'].include? url
    end
    alias_method :gov_cloud?, :gov_cloud

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
    rescue Fog::AWS::Compute::Error
      raise(ActiveRecord::RecordNotFound)
    end

    # Tag Example - <Fog::AWS::Compute::Tag key=nil, value=nil, resource_id=nil, resource_type=nil #>
    def new_tag(attrs = {})
      client.tags.new(attrs)
    end

    def parse_tags(args)
      # Merge AWS EC2 tags
      tags = {}
      if (name = args[:name])
        tags = {:Name => name}
      end

      nested_attrs = args.delete(:tags_attributes)
      args[:tags] = nested_attributes_for(:tags, nested_attrs.deep_symbolize_keys) if nested_attrs

      if args[:tags].present?
        # Validation, must be [{"key": "tags_name", "value": "tag_value"}]
        if !args[:tags].is_a?(Array) || !args[:tags].all? { |item| item.is_a?(Hash) && item.has_key?(:key) && item.has_key?(:value) }
          raise Foreman::Exception.new(N_("Invalid tags, must be an array of maps with key and value properties"))
        end
        args[:tags].each_with_index do |tag, i|
          # Validation against AWS rules
          # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html
          next if tag[:key] =~ /^aws:/
          next unless tag[:key] =~ /^[\p{L}\p{N} +-=._:\/@]{1,128}$/
          next unless tag[:value] =~ /^[\p{L}\p{N} +-=._:\/@]{1,256}$/
          tags[tag[:key]] = tag[:value]
        end
      end
      Foreman::Logging.logger('app').info "AWS machine #{args[:name]} will be created with tags #{tags}"
      tags
    end

    def create_vm(args = { })
      args[:tags] = parse_tags(args)
      args = vm_instance_defaults.merge(args.to_h.symbolize_keys).deep_symbolize_keys
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
    alias_method :available_security_groups, :security_groups

    def regions
      return [] if user.blank? || password.blank?
      @regions ||= client.describe_regions.body["regionInfo"].map { |r| r["regionName"] }
    end

    def zones
      @zones ||= client.describe_availability_zones.body["availabilityZoneInfo"].map { |r| r["zoneName"] if r["regionName"] == region }.compact
    end
    alias_method :available_zones, :zones

    def test_connection(options = {})
      super
      errors[:user].empty? && errors[:password].empty? && regions
    rescue Fog::AWS::Compute::Error => e
      errors[:base] << e.message
    rescue Excon::Error::Socket => e
      errors[:base] << e.message
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      vm.console_output.body.merge(:type => 'log', :name => vm.name)
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

    def associated_host(vm)
      associate_by("ip", [vm.public_ip_address, vm.private_ip_address])
    end

    def user_data_supported?
      true
    end

    def image_exists?(image)
      client.images.get(image).present?
    end

    def normalize_vm_attrs(vm_attrs)
      normalized = slice_vm_attributes(vm_attrs, ['flavor_id', 'availability_zone', 'subnet_id', 'image_id', 'managed_ip'])

      normalized['flavor_name'] =  flavors.detect { |f| f.id == normalized['flavor_id'] }.try(:name)
      normalized['subnet_name'] =  subnets.detect { |f| f.subnet_id == normalized['subnet_id'] }.try(:cidr_block)
      normalized['image_name'] = images.find_by(:uuid => vm_attrs['image_id']).try(:name)

      group_ids = vm_attrs['security_group_ids'] || []
      group_ids = group_ids.select { |gid| gid != '' }
      normalized['security_groups'] = group_ids.map.with_index do |gid, idx|
        [idx.to_s, {
          'id' => gid,
          'name' => security_groups.detect { |g| g.group_id == gid }.try(:name),
        }]
      end.to_h

      normalized
    rescue Fog::AWS::Compute::Error => e
      Foreman::Logging.exception("Unhandled EC2 error", e)
      {}
    end

    private

    def subnet_implies_is_vpc?(args)
      args[:subnet_id].present?
    end

    def client
      self.url = region if gov_cloud
      @client ||= Fog::AWS::Compute.new(:aws_access_key_id => user, :aws_secret_access_key => password, :region => region, :connection_options => connection_options)
    end

    def vm_instance_defaults
      super.merge(
        :flavor_id => "m1.small",
        :key_pair  => key_pair
      )
    end
  end
end
