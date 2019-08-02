class OrganizationParameter < Parameter
  audited :except => [:priority, :searchable_value], :associated_with => :organization
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :organization, :presence => true

  def associated_type
    N_('organization')
  end

  def associated_label
    organization.to_label
  end

  private

  def enforce_permissions(operation)
    # We get called again with the operation being set to create
    return true if operation == "edit" && new_record?
    return true if User.current.allowed_to?("#{operation}_organizations".to_sym)

    errors.add(:base, _("You do not have permission to %s this organization parameter") % operation)
    false
  end
end
