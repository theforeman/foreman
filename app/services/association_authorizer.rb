class AssociationAuthorizer
  def self.authorized_associations(associations,  klass_name = nil, should_raise_exception = true)
    if associations.included_modules.include?(Authorizable)
      associations_klass = associations
      if associations.respond_to?(:klass)
        associations_klass = associations.klass
      end
      klass_name ||= associations_klass
      permission = view_permission_name(klass_name, should_raise_exception)
      associations.authorized(permission, associations_klass) if permission
    else
      associations
    end
  end

  def self.view_permission_name(klass, should_raise_exception)
    permission = "view_#{klass.to_s.underscore.pluralize}"
    if Permission.where(:name => permission).present?
      permission
    elsif should_raise_exception
      raise Foreman::Exception.new(N_('unknown permission %s'), permission)
    else
      false
    end
  end
end
