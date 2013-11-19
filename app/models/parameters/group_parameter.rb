class GroupParameter < Parameter
  belongs_to :system_group, :foreign_key => :reference_id
  audited :except => [:priority], :associated_with => :system_group, :allow_mass_assignment => true
  validates :name, :uniqueness => {:scope => :reference_id}

  private
  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?

    current = User.current

    if current.allowed_to?("#{operation}_params".to_sym)
      if current.system_groups.empty? or current.system_groups.include? system_group
        return true
      end
    end

    errors.add(:base, _("You do not have permission to %s this group parameter") % operation)
    false
  end
end
