object @resource

if params.has_key?(:include_permissions)
  node do |resource|
    if resource&.class&.try(:include?, Authorizable)
      # To avoid loading all the records into the cache
      # authorized_for is used instead of authorizer.can?.
      node(:can_edit) { authorized_for(:auth_object => resource, :authorizer => authorizer, :permission => "edit_#{controller_permission}") }
      node(:can_delete) { authorized_for(:auth_object => resource, :authorizer => authorizer, :permission => "destroy_#{controller_permission}") }
    end
  end
end
