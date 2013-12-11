object @auth_source_ldap

extends "api/v2/auth_source_ldaps/base"

attributes :port, :account, :base_dn, :ldap_filter, :attr_login, :attr_firstname, :attr_lastname, :attr_mail, :onthefly_register, :tls, :created_at, :updated_at
