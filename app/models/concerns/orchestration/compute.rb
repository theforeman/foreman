module Orchestration::Compute
  extend ActiveSupport::Concern

  included do
    attr_accessor :compute_attributes, :vm, :provision_method
    after_validation :validate_compute_provisioning, :queue_compute
    before_destroy :queue_compute_destroy
  end

  def compute?
    compute_resource_id.present? and compute_attributes.present?
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

  protected
  def queue_compute
    return unless compute? and errors.empty?
    new_record? ? queue_compute_create : queue_compute_update
  end

  def queue_compute_create
    queue.create(:name   => _("Settings up compute instance %s") % self, :priority => 1,
                 :action => [self, :setCompute])
    queue.create(:name   => _("Acquiring IP address for %s") % self, :priority => 2,
                 :action => [self, :setComputeIP]) if compute_resource.provided_attributes.keys.include?(:ip)
    queue.create(:name   => _("Querying instance details for %s") % self, :priority => 3,
                 :action => [self, :setComputeDetails])
    queue.create(:name   => _("Power up compute instance %s") % self, :priority => 1000,
                 :action => [self, :setComputePowerUp]) if compute_attributes[:start] == '1'
  end

  def queue_compute_update
    return unless compute_update_required?
    logger.debug("Detected a change is required for Compute resource")
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
    self.vm = compute_resource.create_vm compute_attributes.merge(:name => name)
  rescue => e
    failure _("Failed to create a compute %{compute_resource} instance %{name}: %{message}\n ") % { :compute_resource => compute_resource, :name => name, :message => e.message }, e.backtrace.join("\n ")
  end

  def setComputeDetails
    if vm
      attrs = compute_resource.provided_attributes
      normalize_addresses if attrs.keys.include?(:mac) or attrs.keys.include?(:ip)

      attrs.each do |foreman_attr, fog_attr |
        # we can't ensure uniqueness of #foreman_attr using normal rails validations as that gets in a later step in the process
        # therefore we must validate its not used already in our db.
        value = vm.send(fog_attr)
        self.send("#{foreman_attr}=", value)

        if value.blank? or (other_host = Host.send("find_by_#{foreman_attr}", value))
          delCompute
          return failure("#{foreman_attr} #{value} is already used by #{other_host}") if other_host
          return failure("#{foreman_attr} value is blank!")
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
      logger.info "waiting for instance to acquire ip address"
      vm.wait_for { self.send(attrs[:ip]).present? }
    end
  rescue => e
    failure _("Failed to get IP for %{name}: %{e}") % { :name => name, :e => e }, e.backtrace
  end

  def delComputeIP;end

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
    return false unless compute_resource.supports_update?
    old.compute_attributes = compute_resource.find_vm_by_uuid(uuid).attributes
    compute_resource.update_required?(old.compute_attributes, compute_attributes.symbolize_keys)
  end

  def validate_compute_provisioning
    return true if compute_attributes.nil?
    image_uuid = compute_attributes[:image_id] || compute_attributes[:image_ref]
    return true if image_uuid.blank?
    img = Image.where(:uuid => image_uuid, :compute_resource_id => compute_resource_id).first
    if img
      self.image = img
    else
      failure(_("Selected image does not belong to %s") % compute_resource) and return false
    end
  end

end
