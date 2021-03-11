require 'socket'
require 'timeout'

module Orchestration::Compute
  extend ActiveSupport::Concern
  include Orchestration::Common

  included do
    attr_accessor :compute_attributes
    after_validation :validate_compute_provisioning, :queue_compute
    before_destroy :queue_compute_destroy
  end

  def reload
    super
    @compute = nil
  end

  def compute?
    compute_resource_id.present? && (compute_attributes.present? || uuid.present?)
  end

  def compute_object
    if uuid.present? && compute_resource_id.present?
      compute_resource.find_vm_by_uuid(uuid) rescue nil
      # we don't want the fact that we failed to fetch the information to break foreman
      # this is mostly relevant when the orchestration had a failure, and later on in the ui we try to retrieve the server again.
      # or when the server was removed not via foreman.
    elsif compute_resource_id.present? && compute_attributes
      compute_resource.new_vm compute_attributes
    end
  end

  def compute_provides?(attr)
    return false if compute_resource.nil?
    compute_resource.provided_attributes.key?(attr)
  end

  def vm_name
    Foreman::Deprecation.deprecation_warning('3.0', 'use Host#compute to deal with vm attributes')
    compute.vm_name
  end

  def compute
    @compute ||= compute_resource&.compute_for(host)
  end

  def vm
    compute.vm
  end

  protected

  def queue_compute
    return log_orchestration_errors unless compute? && errors.empty?
    # Create a new VM if it doesn't already exist or update an existing vm
    vm_exists? ? queue_compute_update : queue_compute_create
  end

  def queue_compute_create
    if find_image.try(:user_data)
      queue.create(:name   => _("Render user data template for %s") % self, :priority => 2,
                   :action => [self, :setUserData])
    end
    queue.create(:name   => _("Set up compute instance %s") % self, :priority => 3,
                 :action => [self, :setCompute])
    if compute_provides?(:ip) || compute_provides?(:ip6)
      queue.create(:name   => _("Acquire IP addresses for %s") % self, :priority => 4,
                   :action => [self, :setComputeIP])
    end
    queue.create(:name   => _("Query instance details for %s") % self, :priority => 5,
                 :action => [self, :setComputeDetails])
    if compute_provides?(:mac) && (mac_based_ipam?(:subnet) || mac_based_ipam?(:subnet6))
      queue.create(:name   => _("Set IP addresses for %s") % self, :priority => 6,
                   :action => [self, :setComputeIPAM])
    end
    if compute_attributes && compute_attributes[:start] == '1'
      queue.create(:name   => _("Power up compute instance %s") % self, :priority => 1000,
                   :action => [self, :setComputePowerUp])
    end
  end

  def queue_compute_update
    return unless compute_update_required?
    logger.debug("Detected a change is required for compute resource")
    queue.create(:name   => _("Compute resource update for %s") % old, :priority => 7,
                 :action => [self, :setComputeUpdate])
  end

  def queue_compute_destroy
    return unless errors.empty? && compute_resource_id.present? && uuid
    queue.create(:name   => _("Removing compute instance %s") % self, :priority => 100,
                 :action => [self, :delCompute])
  end

  def setCompute
    logger.info "Adding Compute instance for #{name}"
    if compute_attributes.nil?
      failure _("Failed to find compute attributes, please check if VM %s was deleted") % name
      return false
    end
    compute.attributes = compute_attributes
    compute.save
  rescue => e
    failure _("Failed to create a compute %{compute_resource} instance %{name}: %{message}\n ") % { :compute_resource => compute_resource, :name => name, :message => e.message }, e
  end

  def setUserData
    logger.info "Rendering UserData template for #{name}"
    template   = provisioning_template(:kind => "user_data")
    @host      = self
    # For some reason this renders as 'built' in spoof view but 'provision' when
    # actually used. For now, use foreman_url('built') in the template
    if template.nil?
      failure((_("%{image} needs user data, but %{os_link} is not associated to any provisioning template of the kind user_data. Please associate it with a suitable template or uncheck 'User data' for %{compute_resource_image_link}.") %
      { :image => image.name,
        :os_link => "<a target='_blank' rel='noopener noreferrer' href='#{edit_operatingsystem_path(operatingsystem)}'>#{operatingsystem.title}</a>",
        :compute_resource_image_link =>
          "<a target='_blank' rel='noopener noreferrer' href='#{edit_compute_resource_image_path(:compute_resource_id => compute_resource.id, :id => image.id)}'>#{image.name}</a>"}).html_safe)
      return false
    end

    compute_attributes[:user_data] = render_template(template: template)

    return false if errors.any?
    logger.info "Revoked old certificates and enabled autosign for UserData"
    true
  end

  def delUserData
    # Mostly copied from SSHProvision, should probably refactor to have both use a common set of PuppetCA actions
    compute_attributes.except!(:user_data) # Unset any badly formatted data
    # since we enable certificates/autosign via here, we also need to make sure we clean it up in case of an error
    if puppetca?
      respond_to?(:initialize_puppetca, true) && initialize_puppetca && delCertificate && delAutosign
    else
      true
    end
  rescue => e
    failure _("Failed to remove certificates for %{name}: %{e}") % { :name => name, :e => e }, e
  end

  def setComputeDetails
    if vm
      attrs = compute_resource.provided_attributes

      attrs.each do |foreman_attr, fog_attr|
        if foreman_attr == :mac
          return false unless match_macs_to_nics(fog_attr)
        elsif [:ip, :ip6].include?(foreman_attr)
          value = vm.send(fog_attr) || find_address(foreman_attr)
          send("#{foreman_attr}=", value)
          return false if send(foreman_attr).present? && !validate_foreman_attr(value, ::Nic::Base, foreman_attr)
        else
          value = vm.send(fog_attr)
          send("#{foreman_attr}=", value)
          return false unless validate_required_foreman_attr(value, Host, foreman_attr)
        end
      end

      if ip.blank? && ip6.blank? && (compute_provides?(:ip) || compute_provides?(:ip6))
        return failure(_("Failed to acquire IP addresses from compute resource for %s") % name)
      end

      true
    else
      failure _("failed to save %s") % name
    end
  end

  def delComputeDetails
  end

  def setComputeIP
    attrs = compute_resource.provided_attributes
    if attrs.key?(:ip) || attrs.key?(:ip6)
      logger.info "Waiting for #{name} to become ready"
      compute_resource.vm_ready vm
      logger.info "waiting for instance to acquire ip address"
      vm.wait_for do
        (attrs.key?(:ip) && send(attrs[:ip]).present?) ||
          (attrs.key?(:ip6) && send(attrs[:ip6]).present?) ||
          ip_addresses.present?
      end
    end
  rescue => e
    failure _("Failed to get IP for %{name}: %{e}") % { :name => name, :e => e }, e
  end

  def delComputeIP
  end

  def setComputeIPAM
    set_ip_address

    unless required_ip_addresses_set?(false)
      failure _('Failed to set IPs via IPAM for %{name}: %{e}') % {:name => name, :e => primary_interface.errors.full_messages.to_sentence }
      return false
    end
    true
  rescue => e
    failure _("Failed to set IP for %{name}: %{e}") % { :name => name, :e => e }, e
  end

  def delComputeIPAM
  end

  def delCompute
    logger.info "Removing Compute instance for #{name}"
    compute_resource.destroy_vm uuid
  rescue => e
    failure _("Failed to destroy a compute %{compute_resource} instance %{name}: %{e}") % { :compute_resource => compute_resource, :name => name, :e => e }, e
  end

  def setComputePowerUp
    logger.info "Powering up Compute instance for #{name}"
    compute_resource.start_vm uuid
  rescue => e
    failure _("Failed to power up a compute %{compute_resource} instance %{name}: %{e}") % { :compute_resource => compute_resource, :name => name, :e => e }, e
  end

  def delComputePowerUp
    logger.info "Powering down Compute instance for #{name}"
    compute_resource.stop_vm uuid
  rescue => e
    failure _("Failed to stop compute %{compute_resource} instance %{name}: %{e}") % { :compute_resource => compute_resource, :name => name, :e => e }, e
  end

  def setComputeUpdate
    logger.info "Update Compute instance for #{name}"
    compute_resource.save_vm uuid, compute_attributes
  rescue => e
    failure _("Failed to update a compute %{compute_resource} instance %{name}: %{e}") % { :compute_resource => compute_resource, :name => name, :e => e }, e
  end

  def delComputeUpdate
    logger.info "Undo Update Compute instance for #{name}"
    compute_resource.save_vm uuid, old.compute_attributes
  rescue => e
    failure _("Failed to undo update compute %{compute_resource} instance %{name}: %{e}") % { :compute_resource => compute_resource, :name => name, :e => e }, e
  end

  private

  def compute_update_required?
    return false unless compute_resource.supports_update? && !compute_attributes.nil?
    attrs = compute.attributes
    old.compute_attributes = attrs if old
    compute_resource.update_required?(attrs, compute_attributes.symbolize_keys)
  end

  def find_image
    return nil if compute_attributes.nil?
    image_uuid = compute_attributes[:image_id] || compute_attributes[:image_ref]
    return nil if image_uuid.blank?
    Image.find_by(:uuid => image_uuid, :compute_resource_id => compute_resource_id)
  end

  def validate_compute_provisioning
    return true if compute_attributes.nil?
    if image_build?
      return true if (compute_attributes[:image_id] || compute_attributes[:image_ref]).blank?
      img = find_image
      if img
        self.image = img
      else
        failure(_("Selected image does not belong to %s") % compute_resource)
        false
      end
    else
      # don't send the image information to the compute resource unless using the image provisioning method
      [:image_id, :image_ref].each { |image_key| compute_attributes.delete(image_key) }
    end
  end

  def find_address(type)
    vm_addresses = filter_ip_addresses(vm.ip_addresses, type)

    # We can exit early if the host already has any kind of ip and the vm does not
    # provide one for this kind to speed up things
    return if (ip.present? || ip6.present?) && vm_addresses.empty?

    # We need to return fast for user-data, so that we save the host before
    # cloud-init finishes, even if the IP is not reachable by Foreman. We do have
    # to return a real IP though, or Foreman will fail to save the host.
    return vm_addresses.first if (vm_addresses.present? && compute_attributes[:user_data].present?)

    # Loop over the addresses waiting for one to come up
    ip = nil
    begin
      Timeout.timeout(120) do
        until ip
          ip = filter_ip_addresses(vm.ip_addresses, type).detect { |addr| ssh_open?(addr) }
          sleep 2 unless ip
        end
      end
    rescue Timeout::Error
      # User-data-based images don't need Foreman to connect at all, so we
      # can return any old ip address here and Foreman won't care. SSH-finish-based
      # images do require an IP, but it's more accurate to return something here
      # if we have it, and let the SSH orchestration fail (and notify) for an
      # unreachable IP
      ip = filter_ip_addresses(vm.ip_addresses, type).first if ip.blank?
      logger.info "acquisition of #{type} address timed out, using #{ip}"
    end
    ip
  end

  def filter_ip_addresses(addresses, type)
    check_method = (type == :ip6) ? :ipv6? : :ipv4?
    addresses.map { |ip| IPAddr.new(ip) rescue nil }.compact.select(&check_method).map(&:to_s)
  end

  def ssh_open?(ip)
    begin
      Timeout.timeout(1) do
        s = TCPSocket.new(ip, 22)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH
        return false
      end
    rescue Timeout::Error
    end

    false
  end

  def validate_foreman_attr(value, object, attr)
    value = value.to_s if object.type_for_attribute(attr.to_s).type == :string
    # we can't ensure uniqueness of #foreman_attr using normal rails
    # validations as that gets in a later step in the process
    # therefore we must validate its not used already in our db.
    if (other_object = object.send("find_by_#{attr}", value))
      return failure("#{attr} #{value} is already used by #{other_object}")
    end
    true
  end

  def validate_required_foreman_attr(value, object, attr)
    return failure("#{attr} value is blank!") if value.blank?
    validate_foreman_attr(value, object, attr)
  end

  def match_macs_to_nics(fog_attr)
    # mac/ip are properties of the NIC, and there may be more than one,
    # so we need to loop. First store the nics returned from Fog in a local
    # array so we can delete from it safely
    fog_nics = vm.interfaces.dup

    logger.debug "Orchestration::Compute: Trying to match network interfaces from fog #{fog_nics.inspect}"
    interfaces.select(&:physical?).each do |nic|
      selected_nic = vm.select_nic(fog_nics, nic)
      if selected_nic.nil? # found no matching fog nic for this Foreman nic
        logger.warn "Orchestration::Compute: Could not match network interface #{nic.inspect}"
        return failure(_("Could not find virtual machine network interface matching %s") % [nic.identifier, nic.ip, nic.name, nic.type].find(&:present?))
      end

      mac = selected_nic.send(fog_attr)
      logger.debug "Orchestration::Compute: nic #{nic.inspect} assigned to #{selected_nic.inspect}"
      nic.mac = mac
      nic.reset_dhcp_record_cache if nic.respond_to?(:reset_dhcp_record_cache) # delete the cached dhcp_record with old MAC on managed nics
      fog_nics.delete(selected_nic) # don't use the same fog nic twice

      # In future, we probably want to skip validation of macs/ips on the Nic
      # macs can be duplicated if we are creating bonds
      # ips can be duplicated if we have isolated subnets (needs an update in the Subnet model first)
      # For now, we scope to physical devices only for the validations

      # validate_foreman_attr handles the failure msg, so we just bubble
      # the false state up the stack
      return false unless validate_required_foreman_attr(mac, Nic::Base.physical, :mac)
    end
    true
  end

  def vm_exists?
    Foreman::Deprecation.deprecation_warning('3.0', 'use Host#compute to deal with vm attributes')
    compute.vm.persisted?
  end
end
