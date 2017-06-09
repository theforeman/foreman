module Foreman::Controller::Parameters::AuthSourceLdap
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix

  class_methods do
    def auth_source_ldap_params_filter
      Foreman::ParameterFilter.new(::AuthSourceLdap).tap do |filter|
        filter.permit :account,
          :account_password,
          :attr_firstname,
          :attr_lastname,
          :attr_login,
          :attr_mail,
          :attr_photo,
          :base_dn,
          :groups_base,
          :host,
          :ldap_filter,
          :name,
          :onthefly_register,
          :port,
          :server_type,
          :tls,
          :usergroup_sync,
          :use_netgroups

        add_taxonomix_params_filter(filter)
      end
    end
  end

  def auth_source_ldap_params
    self.class.auth_source_ldap_params_filter.filter_params(params, parameter_filter_context)
  end
end
