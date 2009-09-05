class HostParameter < Parameter
  belongs_to :host
  validates_presence_of :host_id
end
