class SystemParameter < Parameter
  belongs_to_system :foreign_key => :reference_id
  audited :except => [:priority], :associated_with => :system, :allow_mass_assignment => true
  validates :name, :uniqueness => {:scope => :reference_id}

  def to_s
    "#{system.id ? system.name : "unassociated"}: #{name} = #{value}"
  end

  private
  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?

    (auth = User.current.allowed_to?("#{operation}_params".to_sym)) and System.my_systems.include?(system)

    errors.add(:base, _("You do not have permission to %s this domain") % operation) unless auth
    auth
  end
end
