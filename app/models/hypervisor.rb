require_dependency 'hypervisor/guest'

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

  # interfaces is a special case with libvirt, as its supported only on platforms that run netcf
  def interfaces
    query {host.interfaces + host.networks}
  rescue => e
    logger.debug e.to_s
    []
  end

  def storage_pools
    query {host.storage_pools.map(&:name)}
  end

  def to_param
    name
  end

  def guests
    query { Virt::Guest.all }
  end

  def memory
    query {host.connection.node_get_info.memory }
  end

  def free_memory
    query {host.connection.node_free_memory } rescue nil
  end

  def cpus
    query {host.connection.node_get_info.cpus}
  end

  def connect
    logger.info "trying to contact Hypervisor #{name}"
    @host = Virt.connect(uri).host
  end

  def disconnect
    logger.debug "Closing connection to #{self}"
    host.disconnect if host
  end

  private
  def try_to_connect
    return true if Rails.env == "test"
    return true if Virt.connect(uri)
  rescue => e
    errors.add_to_base "Unable to connect to Hypervisor: #{e}"
    false
  ensure
    Virt.connection.disconnect rescue false
  end

  # we query the hypervisor
  # if the conntection was open before, we leave it open
  # otherwise we open and close the connection
  def query
    c = connected?
    connect unless c
    result = yield if block_given?
    disconnect unless c
    return result
  end

  def connected?
    return true if @host and not @host.closed?
    false
  end

end
