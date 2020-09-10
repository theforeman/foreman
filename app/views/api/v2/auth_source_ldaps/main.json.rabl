object @auth_source_ldap

extends "api/v2/auth_source_ldaps/base"

attributes :host, :port, :account, :base_dn, :ldap_filter, :attr_login, :attr_firstname, :attr_lastname,
  :attr_mail, :attr_photo, :onthefly_register, :usergroup_sync, :tls, :server_type, :groups_base,
  :use_netgroups, :created_at, :updated_at
