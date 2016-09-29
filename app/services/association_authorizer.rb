class AssociationAuthorizer
  def self.authorized_associations(associations, klass_name = nil, should_raise_exception = true, action = 'view')
    if associations.included_modules.include?(Authorizable)
      associations_klass = associations
      if associations.respond_to?(:klass)
        associations_klass = associations.klass
      end
      klass_name ||= associations_klass
      permission = permission_name(klass_name, action, should_raise_exception)
      associations.authorized(permission, associations_klass) if permission
    else
      associations
    end
  end

  def self.permission_name(klass, permission, should_raise_exception)
    suffix = klass.respond_to?(:permission_name) ? klass.permission_name : klass.to_s.underscore.pluralize
    permission = "#{permission}_#{suffix}"
    if Permission.where(:name => permission).present?
      permission
    elsif should_raise_exception
      raise Foreman::Exception.new(N_('unknown permission %s'), permission)
    else
      false
    end
  end
end
