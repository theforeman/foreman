class GraphqlAttribute
  attr_reader :resource_class

  def self.for(resource_class)
    new(resource_class: resource_class)
  end

  def initialize(resource_class:)
    @resource_class = resource_class
  end

  def required?(attribute)
    return false unless resource_class

    return true if resource_class.columns_hash[attribute.to_s]&.null == false

    return true if resource_class.validators_on(attribute).find do |validator|
      validator.is_a?(ActiveModel::Validations::PresenceValidator) && ([:if, :unless] & validator.options.keys).none?
    end

    reflection = resource_class.reflect_on_association(attribute)
    return true if reflection && reflection.macro == :belongs_to && required?(reflection.foreign_key)

    false
  end
end
