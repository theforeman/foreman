module Orchestration::Libvirt
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      include Vm
      attr_accessor :powerup
      after_validation  :initialize_libvirt, :queue_libvirt
      before_destroy    :initialize_libvirt, :queue_libvirt_destroy
    end
  end

  module InstanceMethods
    def libvirt?
      hypervisor? and !memory.blank? and !vcpu.blank? and !storage_pool.blank? and \
      !interface.blank? and !network_type.blank? and !disk_size.blank?
    end

    protected
    def initialize_libvirt
      return unless libvirt?
      (@hypervisor = Hypervisor.find(hypervisor_id)).connect
      @guest = @hypervisor.host.create_guest({:name => name, :memory => memory, :arch => architecture.name,
                                              :vcpu => vcpu, :pool => storage_pool, :size => disk_size,
                                              :device => interface, :type => network_type})
    rescue => e
      failure "Failed to initialize the Libvirt connection: #{e}"
    end

    def queue_libvirt
      return unless libvirt? and errors.empty?
      new_record? ? queue_libvirt_create : queue_libvirt_update
    end

    def queue_libvirt_create
      queue.create(:name => "Libvirt: Settings up storage for instance #{self}", :priority => 1,
                   :action => [self, :setLibvirtVolume])
      queue.create(:name => "Settings up libvirt instance #{self}", :priority => 2,
                   :action => [self, :setLibvirt])
      queue.create(:name => "Settings up libvirt instance #{self} to start", :priority => 1000,
                   :action => [self, :setPowerUp]) if powerup
      queue.create(:name => "Disconnect from hypervisor", :priority => 1001,
                   :action => [self, :setDisconnectFromHypervisor])
    end

    def queue_libvirt_update
    end

    def queue_libvirt_destroy
      return unless errors.empty?
      return unless libvirt? or (hostgroup and hostgroup.hypervisor?)
      @hypervisor ||= hostgroup.hypervisor.connect
      @guest ||= Virt::Guest.find(name) rescue nil
      return if @guest.nil?
      queue.create(:name => "Removing libvirt instance #{self}", :priority => 1,
                   :action => [self, :delLibvirt])
      queue.create(:name => "Removing libvirt Storage #{self}", :priority => 2,
                   :action => [self, :delLibvirtVolume])
    end

    def setLibvirtVolume
      logger.info "Adding Libvirt instance storage for #{name}"
      @guest.volume.save
    rescue => e
      failure "Failed to create Storage for Libirt instance #{name}: #{e}"
    end

    def delLibvirtVolume
      logger.info "Removing Libvirt instance storage for #{name}"
      @guest.volume.destroy
    rescue => e
      failure "Failed to destroy Storage for Libirt instance #{name}: #{e}"
    end

    def setLibvirt
      logger.info "Adding Libvirt instance for #{name}"
      if @guest.save and !(self.mac = @guest.interface.mac).empty?
        # we can't ensure uniqueness of MAC using normal rails validations as the mac gets in a later step in the process
        # therefore we must validate its not used already in our db.
        normalize_addresses
        if other_host = Host.find_by_mac(mac)
          delLibvirt
          return failure("MAC Address #{mac} is already used by #{other_host}")
        end
        true
      else
        failure "failed to save virtual machine"
      end
    rescue => e
      failure "Failed to create Libirt instance #{name}: #{e}"
    end

    def delLibvirt
      logger.info "Removing Libvirt instance for for #{name}"
      @guest.destroy
    rescue => e
      failure "Failed to destroy Libirt instance #{name}: #{e}"
    end

    def setPowerUp
      @guest.start
    rescue => e
      failure "Failed to start Guest: #{e}"
    end

    def delPowerUp
      @guest.stop
    rescue => e
      failure "Failed to stop Guest: #{e}"
    end

    def setDisconnectFromHypervisor
      @hypervisor.disconnect
      true
    end

    def delDisconnectFromHypervisor
      @hypervisor.connect
    end
  end
end
