require 'hypervisor/guest'
require 'timeout'

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
    return true if Rails.env == "test"
    logger.debug "trying to contact Hypervisor #{name}"
    Timeout::timeout(10, StandardError) { @host = Virt.connect(uri).host }
  rescue => e
    logger.warn "Failed to connect to hypervisor #{name} - #{e}"
    @host = nil
    raise
  end

  def disconnect
    return true if Rails.env == "test"
    logger.debug "Closing connection to #{name}"
    Timeout::timeout(10, StandardError) { host.disconnect } if host
  rescue => e
    logger.warn "Failed to disconnect from hypervisor #{name} - #{e}"
    false
  ensure
    @host = nil
  end

  private
  def try_to_connect
    connect
  rescue => e
    errors.add :base, "Unable to connect to Hypervisor: #{e}"
    false
  ensure
    disconnect
  end

  # we query the hypervisor
  # if the connection was open before, we leave it open
  # otherwise we open and close the connection
  def query
    return [] if Rails.env.test?
    c = connected?
    connect unless c
    result = yield if block_given?
    disconnect unless c
    return result
  end

  def connected?
    @host and !@host.closed?
  end

end
