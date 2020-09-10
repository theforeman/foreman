require 'test_helper'

class AuthSourceExternalParametersTest < ActiveSupport::TestCase
  include Foreman::Controller::Parameters::AuthSourceExternal

  let(:context) { Foreman::ParameterFilter::Context.new(:api, 'auth_source_external', 'update') }

  test "filters STI :type field" do
    params = ActionController::Parameters.new(:auth_source_external => {:type => AuthSourceHidden.name})
    refute_includes self.class.auth_source_external_params_filter.filter_params(params, context), 'type'
  end
end
