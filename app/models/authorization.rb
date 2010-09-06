module Authorization
  def self.included(base)
    base.class_eval do
      before_save    :enforce_edit_permissions
      before_destroy :enforce_destroy_permissions
      before_create  :enforce_create_permissions
    end
  end

  # We must enforce the security model
  def enforce_edit_permissions
    enforce_permissions("edit") if enforce?
  end

  def enforce_destroy_permissions
    enforce_permissions("destroy") if enforce?
  end

  def enforce_create_permissions
    enforce_permissions("create") if enforce?
  end

  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?

    klass   = self.class.name.downcase
    klass.gsub!(/authsource.*/, "authenticator")
    klass.gsub!(/commonparameter.*/, "global_variable")
    klasses = klass.pluralize
    return true if User.current.allowed_to?("#{operation}_#{klasses}".to_sym)

    errors.add_to_base "You do not have permission to #{operation} this #{klass}"
    false
  end

  private
  def enforce?
    not (defined?(Rake) or User.current.admin?)
  end
end
