module AuthSourcesHelper
  def number_of_users_counter(users, auth_source_type)
    if auth_source_type == 'AuthSourceOidc'
      linked_user_ids = OidcIdentity.where(:auth_source_id => AuthSourceOidc.with_taxonomy_scope.select(:id)).distinct.pluck(:user_id).to_set
      return users.count { |user| linked_user_ids.include?(user.id) }
    end

    users.count { |user| user.auth_source.type == auth_source_type }
  end

  def ldap_present(auth_sources)
    auth_source = auth_sources.detect { |auth_src| auth_src.type == 'AuthSourceLdap' }
    auth_source = AuthSourceLdap.new if auth_source.nil?
    auth_source
  end

  def type_of_auth_source(auth_source)
    case auth_source.type
    when "AuthSourceLdap"
      type = "LDAP"
    when "AuthSourceInternal"
      type = "Internal"
    when "AuthSourceExternal"
      type = "External"
    when "AuthSourceOidc"
      type = "OpenID Connect"
    end
    type
  end
end
