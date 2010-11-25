class OsParameter < Parameter
  belongs_to :operatingsystem, :foreign_key => :reference_id
  validates_uniqueness_of :name, :scope => :reference_id

  private
  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?
    return true if User.current.allowed_to?("#{operation}_operatingsystems".to_sym)

    errors.add_to_base "You do not have permission to #{operation} this Operating System parameter"
    false
  end

end
