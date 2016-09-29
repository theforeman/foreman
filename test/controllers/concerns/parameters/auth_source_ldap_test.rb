require 'test_helper'

class AuthSourceLdapParametersTest < ActiveSupport::TestCase
  include Foreman::Controller::Parameters::AuthSourceLdap

  let(:context) { Foreman::ParameterFilter::Context.new(:api, 'auth_source_ldap', 'update') }

  test "filters STI :type field" do
    params = ActionController::Parameters.new(:auth_source_ldap => {:type => AuthSourceHidden.name})
    refute_includes self.class.auth_source_ldap_params_filter.filter_params(params, context), 'type'
  end
end
