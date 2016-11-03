module Api::LookupValueConnectorController
  extend ActiveSupport::Concern

  def turn_params_to_values(parameters, match)
    return {} if parameters.nil?
    lookup_values = {}
    parameters.each do |param|
      if param.is_a?(Array)
        param = param[1]
      end
      lookup_values.merge!({:lookup_value => {:key => param[:name], :value => param[:value], :match => match}})
    end

    {:lookup_values_attributes => lookup_values}
  end
end
