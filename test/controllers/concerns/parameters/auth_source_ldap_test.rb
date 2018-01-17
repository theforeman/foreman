require 'test_helper'

class AuthSourceLdapParametersTest < ActiveSupport::TestCase
  include Foreman::Controller::Parameters::AuthSourceLdap

  let(:context) { Foreman::ParameterFilter::Context.new(:api, 'auth_source_ldap', 'update') }

  test "filters STI :type field" do
    params = ActionController::Parameters.new(:auth_source_ldap => {:type => AuthSourceHidden.name})
    assert_raises ActionController::UnpermittedParameters do
      self.class.auth_source_ldap_params_filter.filter_params(params, context)
    end
  end
end
