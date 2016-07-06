class VariableLookupKeysController < LookupKeysController
  include Foreman::Controller::Parameters::VariableLookupKey

  private

  def resource
    @variable_lookup_key
  end

  def resource_params
    variable_lookup_key_params
  end
end
