class HostParameter < Parameter
  belongs_to :host, :foreign_key => :reference_id
  acts_as_audited :except => [:priority], :associated_with => :host
  validates_uniqueness_of :name, :scope => :reference_id

  def to_s
    "#{host.id ? host.name : "unassociated"}: #{name} = #{value}"
  end

  private
  def enforce_permissions operation
  # We get called again with the operation being set to create
  return true if operation == "edit" and new_record?

  if User.current.allowed_to?("#{operation}_params".to_sym)
   return true
  end

  return false
  end
end
