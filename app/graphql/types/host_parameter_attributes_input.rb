module Types
  class HostParameterAttributesInput < BaseInputObject
    argument :name, String, required: true
    argument :value, String, required: true
    argument :parameter_type, String, required: false
    argument :hidden_value, Boolean, required: false
  end
end
