require 'foreman/ldap/ldap_subscriber'
require 'foreman/ldap/ldap_fluff_subscriber'
require 'foreman/ldap/net_ldap_subscriber'

# Debug logging from net-ldap and ldap_fluff events sent via ActiveSupport::Notifications
Rails.application.config.after_initialize do
  Foreman::Ldap::NetLdapSubscriber.attach_to :net_ldap
  Foreman::Ldap::LdapFluffSubscriber.attach_to :ldap_fluff
end
