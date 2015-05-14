require 'socket'
require 'timeout'

module Orchestration::Compute
  extend ActiveSupport::Concern

  included do
    attr_accessor :compute_attributes, :vm
    after_validation :validate_compute_provisioning, :queue_compute
    before_destroy :queue_compute_destroy
  end

  def compute?
    compute_resource_id.present? && ( compute_attributes.present? || uuid.present? )
  end

  def compute_object
    if uuid.present? and compute_resource_id.present?
      compute_resource.find_vm_by_uuid(uuid) rescue nil
      # we don't want the fact that we failed to fetch the information to break foreman
      # this is mostly relevant when the orchestration had a failure, and later on in the ui we try to retrieve the server again.
      # or when the server was removed not via foreman.
    elsif compute_resource_id.present? && compute_attributes
      compute_resource.new_vm compute_attributes
    end
  end

  def compute_provides?(attr)
    compute? && compute_resource.provided_attributes.keys.include?(attr)
  end

  def ip_available?
    ip.present? || compute_provides?(:ip)
  end

  def mac_available?
    mac.present? || compute_provides?(:mac)
  end

  protected

  def queue_compute
    return unless compute? and errors.empty?
    new_record? ? queue_compute_create : queue_compute_update
  end

  def queue_compute_create
    queue.create(:name   => _("Render user data template for %s") % self, :priority => 1,
                 :action => [self, :setUserData]) if find_image.try(:user_data)
    queue.create(:name   => _("Set up compute instance %s") % self, :priority => 2,
                 :action => [self, :setCompute])
    queue.create(:name   => _("Acquire IP address for %s") % self, :priority => 3,
                 :action => [self, :setComputeIP]) if compute_provides?(:ip)
    queue.create(:name   => _("Query instance details for %s") % self, :priority => 4,
                 :action => [self, :setComputeDetails])
    queue.create(:name   => _("Power up compute instance %s") % self, :priority => 1000,
                 :action => [self, :setComputePowerUp]) if compute_attributes[:start] == '1'
  end

  def queue_compute_update
    return unless compute_update_required?
    logger.debug("Detected a change is required for compute resource")
    queue.create(:name   => _("Compute resource update for %s") % old, :priority => 7,
                 :action => [self, :setComputeUpdate])
  end

  def queue_compute_destroy
    return unless errors.empty? and compute_resource_id.present? and uuid
    queue.create(:name   => _("Removing compute instance %s") % self, :priority => 100,
                 :action => [self, :delCompute])
  end

  def setCompute
    logger.info "Adding Compute instance for #{name}"
    add_interfaces_to_compute_attrs
    self.vm = compute_resource.create_vm compute_attributes.merge(:name => Setting[:use_shortname_for_vms] ? shortname : name)
  rescue => e
    failure _("Failed to create a compute %{compute_resource} instance %{name}: %{message}\n ") % { :compute_resource => compute_resource, :name => name, :message => e.message }, e.backtrace
  end

  def setUserData
    logger.info "Rendering UserData template for #{name}"
    template   = configTemplate(:kind => "user_data")
    @host      = self
    # For some reason this renders as 'built' in spoof view but 'provision' when
    # actually used. For now, use foreman_url('built') in the template
    if template.nil?
      failure((_("%{image} needs user data, but %{os_link} is not associated to any provisioning template of the kind user_data. Please associate it with a suitable template or uncheck 'User data' for %{compute_resource_image_link}.") %
      { :image => image.name,
        :os_link => "<a target='_blank' href='#{url_for(edit_operatingsystem_path(operatingsystem))}'>#{operatingsystem.title}</a>",
        :compute_resource_image_link =>
          "<a target='_blank' href='#{url_for(edit_compute_resource_image_path(:compute_resource_id => compute_resource.id, :id => image.id))}'>#{image.name}</a>"}).html_safe)
      return false
    end

    self.compute_attributes[:user_data] = unattended_render(template.template)
    self.handle_ca
    return false if errors.any?
    logger.info "Revoked old certificates and enabled autosign for UserData"
  end

  def delUserData
    # Mostly copied from SSHProvision, should probably refactor to have both use a common set of PuppetCA actions
    compute_attributes.merge!(:user_data => nil) # Unset any badly formatted data
    # since we enable certificates/autosign via here, we also need to make sure we clean it up in case of an error
    if puppetca?
      respond_to?(:initialize_puppetca,true) && initialize_puppetca && delCertificate && delAutosign
    end
  rescue => e
    failure _("Failed to remove certificates for %{name}: %{e}") % { :name => name, :e => e }, e.backtrace
  end

  def setComputeDetails
    if vm
      attrs = compute_resource.provided_attributes

      attrs.each do |foreman_attr, fog_attr |
        if foreman_attr == :mac
          #TODO, do we need handle :ip as well? for openstack / ec2 we only set a single
          # interface (so host.ip will be fine), and we'd need to rethink #find_address :/

          return false unless match_macs_to_nics(fog_attr)
        else
          value = vm.send(fog_attr)
          value ||= find_address if foreman_attr == :ip
          self.send("#{foreman_attr}=", value)

          # validate_foreman_attr handles the failure msg, so we just bubble
          # the false state up the stack
          return false unless validate_foreman_attr(value,Host,foreman_attr)
        end
      end
      true
    else
      failure _("failed to save %s") % name
    end
  end

  def delComputeDetails; end

  def setComputeIP
    attrs = compute_resource.provided_attributes
    if attrs.keys.include?(:ip)
      logger.info "Waiting for #{name} to become ready"
      vm.wait_for { self.ready? }
      logger.info "waiting for instance to acquire ip address"
      vm.wait_for do
        self.send(attrs[:ip]).present? || self.ip_addresses.present?
      end
    end
  rescue => e
    failure _("Failed to get IP for %{name}: %{e}") % { :name => name, :e => e }, e.backtrace
  end

  def delComputeIP; end

  def delCompute
    logger.info "Removing Compute instance for #{name}"
    compute_resource.destroy_vm uuid
  rescue => e
    failure _("Failed to destroy a compute %{compute_resource} instance %{name}: %{e}") % { :compute_resource => compute_resource, :name => name, :e => e }, e.backtrace
  end

  def setComputePowerUp
    logger.info "Powering up Compute instance for #{name}"
    compute_resource.start_vm uuid
  rescue => e
    failure _("Failed to power up a compute %{compute_resource} instance %{name}: %{e}") % { :compute_resource => compute_resource, :name => name, :e => e }, e.backtrace
  end

  def delComputePowerUp
    logger.info "Powering down Compute instance for #{name}"
    compute_resource.stop_vm uuid
  rescue => e
    failure _("Failed to stop compute %{compute_resource} instance %{name}: %{e}") % { :compute_resource => compute_resource, :name => name, :e => e }, e.backtrace
  end

  def setComputeUpdate
    logger.info "Update Compute instance for #{name}"
    compute_resource.save_vm uuid, compute_attributes
  rescue => e
    failure _("Failed to update a compute %{compute_resource} instance %{name}: %{e}") % { :compute_resource => compute_resource, :name => name, :e => e }, e.backtrace
  end

  def delComputeUpdate
    logger.info "Undo Update Compute instance for #{name}"
    compute_resource.save_vm uuid, old.compute_attributes
  rescue => e
    failure _("Failed to undo update compute %{compute_resource} instance %{name}: %{e}") % { :compute_resource => compute_resource, :name => name, :e => e }, e.backtrace
  end

  private

  def compute_update_required?
    return false unless compute_resource.supports_update? and !compute_attributes.nil?
    old.compute_attributes = compute_resource.find_vm_by_uuid(uuid).attributes
    compute_resource.update_required?(old.compute_attributes, compute_attributes.symbolize_keys)
  end

  def find_image
    return nil if compute_attributes.nil?
    image_uuid = compute_attributes[:image_id] || compute_attributes[:image_ref]
    return nil if image_uuid.blank?
    Image.where(:uuid => image_uuid, :compute_resource_id => compute_resource_id).first
  end

  def validate_compute_provisioning
    return true unless image_build?
    return true if ( compute_attributes.nil? or (compute_attributes[:image_id] || compute_attributes[:image_ref]).blank? )
    img = find_image
    if img
      self.image = img
    else
      failure(_("Selected image does not belong to %s") % compute_resource) and return false
    end
  end

  def find_address
    # We need to return fast for user-data, so that we save the host before
    # cloud-init finishes, even if the IP is not reachable by Foreman. We do have
    # to return a real IP though, or Foreman will fail to save the host.
    return vm.ip_addresses.first if ( vm.ip_addresses.present? && self.compute_attributes[:user_data].present? )

    # Loop over the addresses waiting for one to come up
    ip = nil
    begin
      Timeout::timeout(120) do
        until ip
          ip = vm.ip_addresses.find { |addr| ssh_open?(addr) }
          sleep 2
        end
      end
    rescue Timeout::Error
      # User-data-based images don't need Foreman to connect at all, so we
      # can return any old ip address here and Foreman won't care. SSH-finish-based
      # images do require an IP, but it's more accurate to return something here
      # if we have it, and let the SSH orchestration fail (and notify) for an
      # unreachable IP
      ip = vm.ip_addresses.first if ip.blank?
      logger.info "acquisition of ip address timed out, using #{ip}"
    end
    ip
  end

  def ssh_open?(ip)
    begin
      Timeout::timeout(1) do
        begin
          s = TCPSocket.new(ip, 22)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH
          return false
        end
      end
    rescue Timeout::Error
    end

    false
  end

  def add_interfaces_to_compute_attrs
    # We now store vm fields in the Nic model, so we need to add them to
    # compute_attrs before creating the vm
    attrs_name = "#{compute_resource.interfaces_attrs_name}_attributes"
    return unless compute_attributes[attrs_name].blank?
    compute_attributes[attrs_name] = {}
    self.interfaces.each_with_index do |nic, index|
      compute_attributes[attrs_name][index.to_s] = nic.compute_attributes
    end
  end

  def validate_foreman_attr(value,object,attr)
    # we can't ensure uniqueness of #foreman_attr using normal rails
    # validations as that gets in a later step in the process
    # therefore we must validate its not used already in our db.
    if value.blank?
      delCompute
      return failure("#{attr} value is blank!")
    elsif (other_object = object.send("find_by_#{attr}", value))
      delCompute
      return failure("#{attr} #{value} is already used by #{other_object}")
    end
    true
  end

  def match_macs_to_nics(fog_attr)
    # mac/ip are properties of the NIC, and there may be more than one,
    # so we need to loop. First store the nics returned from Fog in a local
    # array so we can delete from it safely
    fog_nics = vm.interfaces.dup

    logger.debug "Orchestration::Compute: Trying to match network interfaces from fog #{fog_nics.inspect}"
    self.interfaces.each do |nic|
      selected_nic = vm.select_nic(fog_nics, nic)
      if selected_nic.nil? # found no matching fog nic for this Foreman nic
        logger.warn "Orchestration::Compute: Could not match network interface #{nic.inspect}"
        return failure(_("Could not find virtual machine network interface matching %s") % [nic.identifier, nic.ip, nic.name, nic.type].find(&:present?))
      end

      mac = selected_nic.send(fog_attr)
      logger.debug "Orchestration::Compute: nic #{nic.inspect} assigned to #{selected_nic.inspect}"
      nic.mac = mac
      fog_nics.delete(selected_nic) # don't use the same fog nic twice

      # In future, we probably want to skip validation of macs/ips on the Nic
      # macs can be duplicated if we are creating bonds
      # ips can be duplicated if we have isolated subnets (needs an update in the Subnet model first)
      # For now, we scope to physical devices only for the validations

      # validate_foreman_attr handles the failure msg, so we just bubble
      # the false state up the stack
      return false unless validate_foreman_attr(mac,Nic::Base.physical,:mac)
    end
    true
  end
end
