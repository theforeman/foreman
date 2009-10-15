class AuthSourcesController < ApplicationController

  active_scaffold :authSourceLdap do |config|
    config.label = "LDAP Autentication"
    config.actions = [:create, :update, :delete, :list]
    config.list.columns = [:name, :host, :tls, :onthefly_register]
    config.columns = [ :name, :host, :port, :tls, :onthefly_register, :account, :account_password, :base_dn, :attr_login, :attr_firstname, :attr_lastname, :attr_mail ]
    config.columns[:tls].form_ui = :checkbox
    config.columns[:onthefly_register].form_ui = :checkbox
    config.columns[:name].description = "Name of this connection"
    config.columns[:host].description = "Your LDAP/AD Host"
    config.columns[:tls].description = "Enable TLS"
    config.columns[:onthefly_register].description = "Auto create users"
    config.columns[:account].description = "Use this account to authenticate, optional"
    config.columns[:account_password].description = "Use this account to authenticate, optional"
    config.columns[:base_dn].description = "LDAP/AD Base_dn"
    config.columns[:attr_login].description = "e.g. uid"
    config.columns[:attr_firstname].description = "e.g. givenName"
    config.columns[:attr_lastname].description = "e.g. sn"
    config.columns[:attr_mail].description = "e.g. mail"
  end

end
