class LocationParameter < Parameter
  belongs_to :location, :foreign_key => :reference_id, :inverse_of => :location_parameters
  audited :except => [:priority], :associated_with => :location, :allow_mass_assignment => true
  validates :name, :uniqueness => {:scope => :reference_id}

  private
  def enforce_permissions(operation)
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?
    return true if User.current.allowed_to?("#{operation}_locations".to_sym)

    errors.add(:base, _("You do not have permission to %s this location parameter") % operation)
    false
  end

end
