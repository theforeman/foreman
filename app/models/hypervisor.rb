class Hypervisor < ActiveRecord::Base
  attr_accessible :name, :uri, :kind
  attr_reader :host

  validates_presence_of :name, :uri, :kind
  validates_uniqueness_of :name, :uri
  before_save :try_to_connect
  default_scope :order => 'LOWER(hypervisors.name)'

  KINDS= %w{libvirt}
  MEMORY_SIZE = (1..8).to_a.map {|n| 2**n*1024*128}
  NETWORK_TYPES = %w{ bridge NAT }

  def connect
    return true if @host and not @host.closed?
    logger.info "trying to contact Hypervisor #{name}"
    @host = Virt.connect(uri).host
  end

  # interfaces is a special case with libvirt, as its supported only on platforms that run netcf
  def interfaces
    connect
    return unless host
    host.interfaces + host.networks
  rescue => e
    logger.debug e.to_s
    []
  end

  def storage_pools
    connect
    return unless host
    host.storage_pools.map(&:name)
  end

  def disconnect
    host.disconnect if host
  end

  private

  def try_to_connect
    return true if Rails.env == "test"
    return true if Virt.connect(uri)
  rescue => e
    errors.add_to_base "Unable to connect to Hypervisor: #{e}"
    false
  end
end
