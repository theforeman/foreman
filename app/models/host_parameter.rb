class HostParameter < Parameter
  belongs_to :host
  validates_presence_of :host_id, :message => "parameters require an associated host", :unless => :nested
  validates_uniqueness_of :name

  def to_s
    "#{host_id ? host.name : "unassociated"}: #{name} = #{value}"
  end

end
