class HostParameter < Parameter
  belongs_to :host, :foreign_key => :reference_id
  validates_uniqueness_of :name, :scope => :reference_id

  def to_s
    "#{host_id ? host.name : "unassociated"}: #{name} = #{value}"
  end

end
