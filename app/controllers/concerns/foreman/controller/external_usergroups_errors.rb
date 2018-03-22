module Foreman::Controller::ExternalUsergroupsErrors
  extend ActiveSupport::Concern

  def suggestion_external_group(exception)
    case exception
    when LdapFluff::Generic::UnauthenticatedException
      _('The authentication source of your external user groups could not '\
        'connect to LDAP with the provided credentials. Please verify the '\
        'credentials are still valid.')
    when Net::LDAP::Error
      _('An error happened trying to connect to LDAP, please verify the '\
        'authentication source host is reachable from your Foreman host and '\
        'is online.')
    when LdapFluff::ActiveDirectory::MemberService::UIDNotFoundException
      _('The groups you added as external user groups were found. '\
        'However, no users inside of them that match with your '\
        'authentication source base DN and filter were found. Please verify '\
        'the external user groups belong in the authentication source filter')
    end
  end

  def external_usergroups_error(group, exception)
    group.errors.add(
      :base,
      _("Could not refresh external usergroups: %{e} - %{message} - %{suggestion}") %
      { :e => exception.class,
        :message => exception.to_s,
        :suggestion => suggestion_external_group(exception) }
    )
  end
end
