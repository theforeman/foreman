class LocationParameter < Parameter
  audited :except => [:priority, :searchable_value], :associated_with => :location
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :location, :presence => true

  def associated_type
    N_('location')
  end

  def associated_label
    location.to_label
  end

  private

  def enforce_permissions(operation)
    # We get called again with the operation being set to create
    return true if operation == "edit" && new_record?
    return true if User.current.allowed_to?("#{operation}_locations".to_sym)

    errors.add(:base, _("You do not have permission to %s this location parameter") % operation)
    false
  end
end
