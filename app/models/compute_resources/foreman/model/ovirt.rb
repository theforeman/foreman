require 'foreman/exception'
require 'uri'

module Foreman::Model
  class Ovirt < ComputeResource
    validates :url, :format => { :with => URI.regexp }
    validates :user, :password, :presence => true
    before_create :update_public_key

    alias_attribute :datacenter, :uuid

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:build, :image]
    end

    def supports_update?
      true
    end

    def provided_attributes
      super.merge({:mac => :mac})
    end

    #FIXME
    def max_cpu_count
      8
    end

    def max_memory
      16*Foreman::SIZE[:giga]
    end

    def quotas
      client.quotas
    end

    def ovirt_quota=(ovirt_quota_id)
      self.attrs[:ovirt_quota_id] = ovirt_quota_id
    end

    def ovirt_quota
      if self.attrs[:ovirt_quota_id].blank?
        nil
      else
        self.attrs[:ovirt_quota_id]
      end
    end

    def templates(opts = {})
      client.templates
    end

    def available_images
      templates
    end

    def template(id)
      compute = client.templates.get(id) || raise(ActiveRecord::RecordNotFound)
      compute.interfaces
      compute.volumes
      compute
    end

    def clusters
      client.clusters
    end

    # Check if HTTPS is mandatory, since rest_client will fail with a POST
    def test_https_required
      RestClient.post url, {} if URI(url).scheme == 'http'
      true
    rescue => e
      case e.message
      when /406/
        true
      else
        raise e
      end
    end
    private :test_https_required

    def test_connection(options = {})
      super
      if errors[:url].empty? and errors[:username].empty? and errors[:password].empty?
        update_public_key options
        datacenters && test_https_required
      end
    rescue => e
      case e.message
        when /404/
          errors[:url] << e.message
        when /302/
          errors[:url] << 'HTTPS URL is required for API access'
        when /401/
          errors[:user] << e.message
        else
          errors[:base] << e.message
      end
    end

    def datacenters(options = {})
      client.datacenters(options).map { |dc| [dc[:name], dc[:id]] }
    end

    def networks(opts = {})
      if opts[:cluster_id]
        client.clusters.get(opts[:cluster_id]).networks
      else
        []
      end
    end

    def available_clusters
      clusters
    end

    def available_networks(cluster_id = nil)
      raise ::Foreman::Exception.new(N_('Cluster ID is required to list available networks')) if cluster_id.nil?
      networks({:cluster_id => cluster_id})
    end

    def available_storage_domains(storage_domain = nil)
      storage_domains
    end

    def storage_domains(opts = {})
      client.storage_domains({:role => 'data'}.merge(opts))
    end

    def start_vm(uuid)
      find_vm_by_uuid(uuid).start(:blocking => true)
    end

    def create_vm(args = {})
      #ovirt doesn't accept '.' in vm name.
      args[:name] = args[:name].parameterize
      if (image_id = args[:image_id])
        args.merge!({:template => image_id})
      end
      vm = super({ :first_boot_dev => 'network', :quota => ovirt_quota }.merge(args))
      begin
        create_interfaces(vm, args[:interfaces_attributes])
        create_volumes(vm, args[:volumes_attributes])
      rescue => e
        destroy_vm vm.id
        raise e
      end
      vm
    end

    def new_vm(attr = {})
      vm = super
      interfaces = nested_attributes_for :interfaces, attr[:interfaces_attributes]
      interfaces.map{ |i| vm.interfaces << new_interface(i)}
      volumes = nested_attributes_for :volumes, attr[:volumes_attributes]
      volumes.map{ |v| vm.volumes << new_volume(v)}
      vm
    end

    def new_interface(attr = {})
      Fog::Compute::Ovirt::Interface.new(attr)
    end

    def new_volume(attr = {})
      Fog::Compute::Ovirt::Volume.new(attr)
    end

    def save_vm(uuid, attr)
      vm = find_vm_by_uuid(uuid)
      vm.attributes.merge!(attr.symbolize_keys).deep_symbolize_keys
      update_interfaces(vm, attr[:interfaces_attributes])
      update_volumes(vm, attr[:volumes_attributes])
      vm.interfaces
      vm.volumes
      vm.save
    end

    def destroy_vm(uuid)
      begin
        find_vm_by_uuid(uuid).destroy
      rescue OVIRT::OvirtException => e
        #404 error are ignored on delete.
        raise e unless e.message =~ /404/
      end
      true
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      raise "VM is not running!" if vm.status == "down"
      if vm.display[:type] =~ /spice/i
        xpi_opts = {:name => vm.name, :address => vm.display[:address], :secure_port => vm.display[:secure_port], :ca_cert => public_key, :subject => vm.display[:subject] }
        opts = if vm.display[:secure_port]
                 { :host_port => vm.display[:secure_port], :ssl_target => true }
               else
                 { :host_port => vm.display[:port] }
               end
        WsProxy.start(opts.merge(:host => vm.display[:address], :password => vm.ticket)).merge(xpi_opts).merge(:type => 'spice')
      else
        WsProxy.start(:host => vm.display[:address], :host_port => vm.display[:port], :password => vm.ticket).merge(:name => vm.name, :type => 'vnc')
      end
    end

    def update_required?(old_attrs, new_attrs)
      return true if super(old_attrs, new_attrs)

      new_attrs[:interfaces_attributes].each do |key, interface|
        return true if (interface[:id].blank? || interface[:_delete] == '1') && key != 'new_interfaces' #ignore the template
      end if new_attrs[:interfaces_attributes]

      new_attrs[:volumes_attributes].each do |key, volume|
        return true if (volume[:id].blank? || volume[:_delete] == '1') && key != 'new_volumes' #ignore the template
      end if new_attrs[:volumes_attributes]

      false
    end

    def associated_host(vm)
      associate_by("mac", vm.interfaces.map(&:mac))
    end

    def self.provider_friendly_name
      "oVirt"
    end

    def public_key
      attrs[:public_key]
    end

    def public_key=(key)
      attrs[:public_key] = key
    end

    protected

    def bootstrap(args)
      client.servers.bootstrap vm_instance_defaults.merge(args.to_hash)
    rescue Fog::Errors::Error => e
      errors.add(:base, e.to_s)
      false
    end

    def client
      return @client if @client
      client = ::Fog::Compute.new(
          :provider         => "ovirt",
          :ovirt_username   => user,
          :ovirt_password   => password,
          :ovirt_url        => url,
          :ovirt_datacenter => uuid,
          :ovirt_ca_cert_store => ca_cert_store(public_key)
      )
      client.datacenters
      @client = client
    rescue => e
      if e.message =~ /SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed/
        raise Foreman::FingerprintException.new(
                  N_("The remote system presented a public key signed by an unidentified certificate authority. If you are sure the remote system is authentic, go to the compute resource edit page, press the 'Test Connection' or 'Load Datacenters' button and submit"),
                  ca_cert)
      else
        raise e
      end
    end

    def update_public_key(options = {})
      return unless public_key.blank? || options[:force]
      client
    rescue Foreman::FingerprintException => e
      self.public_key = e.fingerprint if self.public_key.blank?
    end

    def api_version
      @api_version ||= client.api_version
    end

    def ca_cert_store(cert)
      return if cert.blank?
      OpenSSL::X509::Store.new.add_cert(OpenSSL::X509::Certificate.new(cert))
    rescue => e
      raise _("Failed to create X509 certificate, error: %s" % e.message)
    end

    def ca_cert
      ca_url = URI.parse(url)
      ca_url.path = "/ca.crt"
      http = Net::HTTP.new(ca_url.host, ca_url.port)
      http.use_ssl = (ca_url.scheme == 'https')
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(ca_url.path)
      http.request(request).body
    end

    private

    def create_interfaces(vm, attrs)
      #first remove all existing interfaces
      vm.interfaces.each do |interface|
        #The blocking true is a work-around for ovirt bug, it should be removed.
        vm.destroy_interface(:id => interface.id, :blocking => true)
      end if vm.interfaces
      #add interfaces
      interfaces = nested_attributes_for :interfaces, attrs
      interfaces.map{ |i| vm.add_interface(i)}
      vm.interfaces.reload
    end

    def create_volumes(vm, attrs)
      #add volumes
      volumes = nested_attributes_for :volumes, attrs
      volumes.map do |vol|
        vol[:sparse] = "true"
        vol[:format] = "raw"   if vol[:preallocate] == "1"
        vol[:sparse] = "false" if vol[:preallocate] == "1"
        #The blocking true is a work-around for ovirt bug fixed in ovirt version 3.1.
        vm.add_volume({:bootable => 'false', :quota => ovirt_quota, :blocking => api_version.to_f < 3.1}.merge(vol)) if vol[:id].blank?
      end
      vm.volumes.reload
    end

    def update_interfaces(vm, attrs)
      interfaces = nested_attributes_for :interfaces, attrs
      interfaces.each do |interface|
        vm.destroy_interface(:id => interface[:id]) if interface[:_delete] == '1' && interface[:id]
        vm.add_interface(interface) if interface[:id].blank?
      end
    end

    def update_volumes(vm, attrs)
      volumes = nested_attributes_for :volumes, attrs
      volumes.each do |volume|
        vm.destroy_volume(:id => volume[:id], :blocking => api_version.to_f < 3.1) if volume[:_delete] == '1' && volume[:id].present?
        vm.add_volume({:bootable => 'false', :quota => ovirt_quota, :blocking => api_version.to_f < 3.1}.merge(volume)) if volume[:id].blank?
      end
    end
  end
end
