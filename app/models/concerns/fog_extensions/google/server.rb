module FogExtensions
  module Google
    module Server
      extend ActiveSupport::Concern
      extend Fog::Attributes::ClassMethods

      delegate :flavors, :to => :service

      attribute :network
      attribute :associate_external_ip

      # TODO: remove this, UI using it
      attribute :external_ip

      def persisted?
        creation_timestamp.present?
      end

      def pretty_machine_type
        machine_type.split('/')[-1]
      end

      def image_id
        image_name if disks.present?
      end

      def vm_description
        pretty_machine_type
      end

      def volumes_attributes=(attrs)
      end

      # need to fix - actual disk objects needed
      # getting data =>
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
          service.disks(:server => self)
        else
          list_of_disks
        end
      end

      def vm_ip_address
        # external_ip ? public_ip_address : private_ip_address
        public_ip_address || private_ip_address
      end

      def associate_external_ip
        public_ip_address.present?
      end
    end
  end
end
