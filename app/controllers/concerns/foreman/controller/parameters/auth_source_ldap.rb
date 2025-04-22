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
          :use_netgroups,
          :ldap_group_membership

        add_taxonomix_params_filter(filter)
      end
    end
  end

  def auth_source_ldap_params
    filtered = self.class.auth_source_ldap_params_filter.filter_params(params, parameter_filter_context)
    if filtered.key?("use_netgroups")
      Foreman::Deprecation.deprecation_warning("3.18", "`use_netgroups` parameter is deprecated, use `ldap_group_membership` instead.")

      expected = filtered["use_netgroups"] ? %w(nis_netgroups) : %w(posix rfc4519)
      if filtered["ldap_group_membership"].blank?
        filtered["ldap_group_membership"] = expected.first
      elsif !expected.include?(filtered["ldap_group_membership"])
        ::Rails.logger.warn("Conflicting values for `use_netgroups` and `ldap_group_membership` parameters provided, ignoring `use_netgroups`.")
      end
      filtered.delete("use_netgroups")
    end
    filtered
  end
end
