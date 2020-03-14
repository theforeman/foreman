module FogExtensions
  module Google
    module Server
      extend ActiveSupport::Concern
      extend Fog::Attributes::ClassMethods

      EXTERNAL_NAT_NAME = "External NAT".freeze
      EXTERNAL_NAT_TYPE = "ONE_TO_ONE_NAT".freeze

      attribute :network
      attribute :associate_external_ip

      def to_s
        name || identity
      end

      def state
        status.downcase
      end

      def persisted?
        creation_timestamp.present?
      end

      def pretty_machine_type
        machine_type.split('/')[-1] if machine_type
      end

      def pretty_image_name
        image_name.split('/')[-1] if disks.present?
      end

      def image_id
        service.images.get(pretty_image_name).try(:id) if disks.present? && image_name
      end

      def vm_description
        pretty_machine_type
      end

      def volumes_attributes=(attrs)
      end

      # return [Array<Hash>] for disks in response and doesn't contain disk_size
      # Example -
      # disks=[{
      # :auto_delete=>true,
      # :boot=>true,
      # :device_name=>"persistent-disk-0", :index=>0,
      # :interface=>"SCSI",
      # :kind=>"compute#attachedDisk",
      # :licenses=>["https://www.googleapis.com/compute/v1/projects/centos-cloud/global/licenses/centos-7"],
      # :mode=>"READ_WRITE",
      # :source=>"https://www.googleapis.com/compute/v1/projects/fog-dev/zones/us-east1-b/disks/colin-mennig-dhcp223-86-example-com-disk1",
      # :type=>"PERSISTENT"}]
      def volumes
        list_of_disks = disks
        if list_of_disks[0].is_a? Hash
          requires :identity, :zone
          service.disks.all(
            :zone => zone_name,
            :filter => construct_disk_filter(list_of_disks)
          )
        else
          list_of_disks
        end
      end

      def vm_ip_address
        public_ip_address || private_ip_address
      end

      def associate_external_ip
        external_nat_present?
      end

      # Added a getter method here as this attribute removed from fog-google
      def network
        return nil if network_interfaces.blank?
        network_path = network_interfaces[0][:network]
        network_path ? network_path.split('/')[-1] : nil
      end

      private

      def external_nat_present?
        return false if network_interfaces.blank?
        !!network_interfaces.detect do |nic|
          nic[:access_configs].present? && nic[:access_configs].detect { |c| c[:name].eql?(EXTERNAL_NAT_NAME) }
        end
      end

      def construct_disk_filter(disks_arr)
        disks_arr.map { |d| "(name = \"#{d[:source][/([^\/]+)$/]}\")" }.join(' OR ')
      end
    end
  end
end
