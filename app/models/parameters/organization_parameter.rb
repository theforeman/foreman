class OrganizationParameter < Parameter
  belongs_to :organization, :foreign_key => :reference_id, :inverse_of => :organization_parameters
  audited :except => [:priority], :associated_with => :organization, :allow_mass_assignment => true
  validates :name, :uniqueness => {:scope => :reference_id}

  private
  def enforce_permissions(operation)
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?
    return true if User.current.allowed_to?("#{operation}_organizations".to_sym)

    errors.add(:base, _("You do not have permission to %s this organization parameter") % operation)
    false
  end

end
