class HostAlias < ActiveRecord::Base
  belongs_to :domain
  belongs_to :nic, :foreign_key => :nic_id

  validates :name, :nic_id, :presence => true

  delegate :host, :to => :'nic.host'
  delegate :hostname, :to => :'nic.host.hostname'

  def to_s
    name
  end
end
