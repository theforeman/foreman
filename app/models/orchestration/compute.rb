module Orchestration::Compute
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      attr_accessor :compute_attributes
      after_validation :queue_compute
      before_destroy :queue_compute_destroy
    end
  end

  module InstanceMethods
    def compute?
      compute_resource_id.present? and compute_attributes.present?
    end

    def compute_object
      compute_resource.new_vm compute_attributes if compute_resource_id.present? && compute_attributes
    end

    protected
    def queue_compute
      return unless compute? and errors.empty?
      new_record? ? queue_compute_create : queue_compute_update
    end

    def queue_compute_create
      queue.create(:name   => "Settings up compute instance #{self}", :priority => 1,
                   :action => [self, :setCompute])
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
      queue.create(:name   => "Removing compute instance #{self}", :priority => 1,
                   :action => [self, :delCompute])
    end

    def setCompute
      logger.info "Adding Compute instance for #{name}"
      vm = compute_resource.create_vm compute_attributes.merge(:name => name)

      if vm and !(self.mac = vm.mac).empty?
        # we can't ensure uniqueness of MAC using normal rails validations as the mac gets in a later step in the process
        # therefore we must validate its not used already in our db.
        normalize_addresses
        if other_host = Host.find_by_mac(mac)
          delCompute
          return failure("MAC Address #{mac} is already used by #{other_host}")
        end
        self.uuid = vm.identity
        true
      else
        failure "failed to save virtual machine"
      end
    rescue => e
      failure "Failed to create a compute #{compute_resource} instance #{name}: #{e}", e.backtrace
    end

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
      compute_resource.save_vm uuid, compute_attributes
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
