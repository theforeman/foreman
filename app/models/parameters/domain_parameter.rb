class DomainParameter < Parameter
  belongs_to :domain, :foreign_key => :reference_id
  audited :except => [:priority], :associated_with => :domain, :allow_mass_assignment => true
  validates_uniqueness_of :name, :scope => :reference_id

  private
  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?

    current = User.current

    if current.allowed_to?("#{operation}_domains".to_sym)
      if current.domains.empty? or current.domains.include? domain
        return true
      end
    end

    errors.add(:base, _("You do not have permission to %s this domain parameter") % operation)
    false
  end
end
