class DomainParameter < Parameter
  belongs_to :domain, :foreign_key => :reference_id
  acts_as_audited :except => [:priority], :parent => :domain
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

    errors.add :base, "You do not have permission to #{operation} this domain parameter"
    false
  end
end
