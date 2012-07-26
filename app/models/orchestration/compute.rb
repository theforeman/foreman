module Orchestration::Compute
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      attr_accessor :compute_attributes, :vm, :provision_method
      after_validation :validate_compute_provisioning, :queue_compute
      before_destroy :queue_compute_destroy
    end
  end

  module InstanceMethods
    def compute?
      compute_resource_id.present? and compute_attributes.present? && capabilities.include?(:image)
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
      queue.create(:name   => "Requesting compute instance #{self}", :priority => 1,
                   :action => [self, :requestCompute])
      post_queue.create(:name   => "Setting up compute instance #{self}", :priority => 2,
                   :action => [self, :setCompute])
      post_queue.create(:name   => "Acquiring IP address for #{self}", :priority => 3,
                   :action => [self, :setComputeIP]) if compute_resource.provided_attributes.keys.include?(:ip)
      post_queue.create(:name   => "Querying instance details for #{self}", :priority => 4,
                   :action => [self, :setComputeDetails])
      post_queue.create(:name   => "Power up compute instance #{self}", :priority => 1000,
                   :action => [self, :setComputePowerUp]) if compute_attributes[:start] == '1'
    end

    def queue_compute_update
      return unless compute_update_required?
      self.vm = compute_resource.find_vm_by_uuid uuid
      logger.debug("Detected a change is required for Compute resource")
      queue.create(:name   => "Updating instance details for #{self}", :priority => 3,
                   :action => [self, (vm.ready? ? :setComputePowerUp : :delComputePowerUp)])
      queue.create(:name   => "Compute resource update for #{old}", :priority => 7,
                   :action => [self, :setComputeUpdate])
    end

    def queue_compute_destroy
      return unless errors.empty? and compute_resource_id.present? and uuid
      queue.create(:name   => "Removing compute instance #{self}", :priority => 100,
                   :action => [self, :delCompute])
    end

    def requestCompute
      logger.info "Requesting a compute instance for #{name}"
      self.vm = compute_resource.new_vm compute_attributes.merge(:name => name)
    end

    def setCompute
      logger.info "Adding Compute instance for #{name}"
      template   = ConfigTemplate.find_template (:kind => "user_data", :operatingsystem_id => self.operatingsystem_id,
                                                 :hostgroup_id => self.hostgroup_id, :environment_id => self.environment_id)
      @host = self
      user_data = unattended_render(template.template) if template != nil
      self.vm = compute_resource.create_vm compute_attributes.merge(:name => name, :user_data => user_data)
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

          #  In a busy world, this might introduce a race condition whereby two hosts *could* get the
          # same value.  However, the chance of that is small, and this check allows me to save duplicating 
          # the entire function just to pickup the IP change
          #
          other_host = (value.blank? ? "" : Host.send("find_by_#{foreman_attr}", value))
          if value.blank? or (other_host and other_host != self)
            delCompute
            return failure("#{foreman_attr} #{value} is already used by #{other_host}") if other_host
            return failure("#{foreman_attr} value is blank!")
          end
        end
        self.ip = (self.vm.dns_name.blank? ? "" : Resolv.getaddress(self.vm.dns_name))
        true
      else
        failure "failed to save #{name}"
      end

      #  Now that we have an IP and other details, force an update before any mischeif happens
      self.save(:validate => false)
    end

    def delComputeDetails; end

    def setComputeIP
      attrs = compute_resource.provided_attributes
      if vm and attrs.keys.include?(:ip)
        logger.info "waiting for instance to acquire ip address"
        vm.wait_for { self.send(attrs[:ip]) }
      end
    rescue => e
      logger.error e.backtrace.join("\n")
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
      setComputeIP
      setComputeDetails
    rescue => e
      failure "Failed to power up a compute #{compute_resource} instance #{name}: #{e}", e.backtrace
    end

    def delComputePowerUp
      logger.info "Powering down Compute instance for #{name}"
      if vm
        attrs = compute_resource.provided_attributes
        normalize_addresses if attrs.keys.include?(:mac) or attrs.keys.include?(:ip)

        attrs.each do |foreman_attr, fog_attr |
          # we can't ensure uniqueness of #foreman_attr using normal rails validations as that gets in a later step in the process
          # therefore we must validate its not used already in our db.
          value = vm.send(fog_attr)
          self.send("#{foreman_attr}=", value)
        end
        self.ip = (self.vm.dns_name.blank? ? "" : Resolv.getaddress(self.vm.dns_name))
        true
      else
        failure "failed to save #{name}"
      end
    rescue => e
      failure "Failed to stop compute #{compute_resource} instance #{name}: #{e}", e.backtrace
    end

    def setComputeUpdate
      logger.info "Update Compute instance for #{name}"
      compute_resource.save_vm uuid, compute_attributes
       # In some cases, Fog will not re-save a compute instance, so trap for this as being OK:
       #  Checking on the message is a kludge, hopefully fog will throw a well-defined
       #  exception sometime later.

    rescue => e
      if e.message =~ /resaving an existing object/i
        logger.info "This provider does not support update, continuing on."
      else  
        failure "Failed to update a compute #{compute_resource} instance #{name}: #{e}", e.backtrace
      end
    end

    def delComputeUpdate
      logger.info "Undo Update Compute instance for #{name}"
      compute_resource.save_vm uuid, old.compute_attributes
    rescue => e
      failure "Failed to undo update compute #{compute_resource} instance #{name}: #{e}", e.backtrace
    end

    private

    def compute_update_required?
      return true unless uuid?
      old.compute_attributes = compute_resource.find_vm_by_uuid(uuid).attributes
      compute_resource.update_required?(old.compute_attributes, compute_attributes.symbolize_keys)
    end 

    def validate_compute_provisioning
      return unless compute?
      return if Rails.env == "test"
      status = true
      image_uuid = compute_attributes[:image_id]
      unless (self.image = Image.find_by_uuid(image_uuid))
        status &= failure("Must define an Image to use")
      end

      status
    end

  end
end
