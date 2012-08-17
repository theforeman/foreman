module Orchestration::Compute
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      attr_accessor :compute_attributes, :vm, :provision_method
      after_validation :queue_compute
      before_destroy :queue_compute_destroy
    end
  end

  module InstanceMethods
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
      queue.create(:name   => "Settings up compute instance #{self}", :priority => 1,
                   :action => [self, :setCompute])
      queue.create(:name   => "Acquiring IP address for #{self}", :priority => 2,
                   :action => [self, :setComputeIP]) if compute_resource.provided_attributes.keys.include?(:ip)
      queue.create(:name   => "Querying instance details for #{self}", :priority => 3,
                   :action => [self, :setComputeDetails])
      queue.create(:name   => "Power up compute instance #{self}", :priority => 1000,
                   :action => [self, :setComputePowerUp]) if compute_attributes[:start] == '1'
    end

    def queue_compute_update
      return unless compute_update_required?
      logger.debug("Detected a change is required for Compute resource")
      queue.create(:name   => "Compute resource update for #{old}", :priority => 7,
                   :action => [self, :setComputeUpdate])
    end

    def queue_compute_destroy
      return unless errors.empty? and compute_resource_id.present? and uuid
      queue.create(:name   => "Removing compute instance #{self}", :priority => 100,
                   :action => [self, :delCompute])
    end

    def setCompute
      logger.info "Adding Compute instance for #{name}"
      self.vm = compute_resource.create_vm compute_attributes.merge(:name => name)
    rescue => e
      failure "Failed to create a compute #{compute_resource} instance #{name}: #{e.message}\n " + e.backtrace.join("\n ")
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
        failure "failed to save #{name}"
      end
    end

    def delComputeDetails; end

    def setComputeIP
      attrs = compute_resource.provided_attributes
      if attrs.keys.include?(:ip)
        logger.info "waiting for instance to acquire ip address"
        vm.wait_for { self.send(attrs[:ip]) }
      end
    rescue => e
      failure "Failed to get IP for #{name}: #{e}", e.backtrace
    end

    def delComputeIP;end

    def delCompute
      logger.info "Removing Compute instance for #{name}"
      compute_resource.destroy_vm uuid
    rescue => e
      failure "Failed to destroy a compute #{compute_resource} instance #{name}: #{e}", e.backtrace
    end

    def setComputePowerUp
      logger.info "Powering up Compute instance for #{name}"
      compute_resource.start_vm uuid
    rescue => e
      failure "Failed to power up a compute #{compute_resource} instance #{name}: #{e}", e.backtrace
    end

    def delComputePowerUp
      logger.info "Powering down Compute instance for #{name}"
      compute_resource.stop_vm uuid
    rescue => e
      failure "Failed to stop compute #{compute_resource} instance #{name}: #{e}", e.backtrace
    end

    def setComputeUpdate
      logger.info "Update Compute instance for #{name}"
      if compute_resource.supports_update?
        compute_resource.save_vm uuid, compute_attributes
      else
        true
      end
    rescue => e
      failure "Failed to update a compute #{compute_resource} instance #{name}: #{e}", e.backtrace
    end

    def delComputeUpdate
      logger.info "Undo Update Compute instance for #{name}"
      compute_resource.save_vm uuid, old.compute_attributes
    rescue => e
      failure "Failed to undo update compute #{compute_resource} instance #{name}: #{e}", e.backtrace
    end

    private

    def compute_update_required?
      old.compute_attributes = compute_resource.find_vm_by_uuid(uuid).attributes
      compute_resource.update_required?(old.compute_attributes, compute_attributes.symbolize_keys)
    end

  end
end
