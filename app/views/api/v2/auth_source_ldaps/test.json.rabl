object @auth_source_ldap

extends "api/v2/auth_source_ldaps/base"

node :success do
  locals[:success]
end
node :message do
  locals[:message]
end
