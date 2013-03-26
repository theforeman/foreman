class HostParameter < Parameter
  belongs_to_host :foreign_key => :reference_id
  audited :except => [:priority], :associated_with => :host
  validates_uniqueness_of :name, :scope => :reference_id

  def to_s
    "#{host.id ? host.name : "unassociated"}: #{name} = #{value}"
  end

  private
  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?

    (auth = User.current.allowed_to?("#{operation}_params".to_sym)) and Host.my_hosts.include?(host)

    errors.add(:base, _("You do not have permission to %s this domain") % operation) unless auth
    auth
  end
end
