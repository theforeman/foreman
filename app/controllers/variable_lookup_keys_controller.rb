class VariableLookupKeysController < LookupKeysController
  include Foreman::Controller::Parameters::VariableLookupKey

  def new
    @variable_lookup_key = VariableLookupKey.new
  end

  def create
    @variable_lookup_key = VariableLookupKey.new(resource_params.merge(:lookup_values_attributes => sanitize_attrs))
    if @variable_lookup_key.save
      process_success
    else
      process_error
    end
  end

  private

  def resource
    @variable_lookup_key
  end

  def resource_params
    variable_lookup_key_params
  end
end
