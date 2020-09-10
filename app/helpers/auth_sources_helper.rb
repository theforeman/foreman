module AuthSourcesHelper
  def number_of_users_counter(users, auth_source_type)
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
    end
    type
  end
end
