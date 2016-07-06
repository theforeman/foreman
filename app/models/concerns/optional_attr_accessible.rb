# Compatibility layer for model concerns that wish to support
# protected_attributes (`attr_accessible`) and strong parameters, but don't
# know which the model will be using.
#
# Calling `attr_accessible` on a model using strong parameters activates
# protected_attributes, which shouldn't happen. Use the
# `optional_attr_accessible` class method from this concern instead.
#
# If `attr_accessible` is called later, then the attributes from the concern
# will also be added. However if `attr_accessible` is never called for this
# model, i.e. a model using strong parameters, this concern does nothing.
#
# Model concerns using OptionalAttrAccessible should _also_ provide controller
# concerns to help set up ParameterFilter.
#
module OptionalAttrAccessible
  extend ActiveSupport::Concern

  module ClassMethods
    def optional_attr_accessible(*args)
      @optional_attr_accessible ||= []
      @optional_attr_accessible.push(*args)
    end

    def attr_accessible(*args)
      if @optional_attr_accessible
        Foreman::Deprecation.deprecation_warning('1.15', "#{name} is using Foreman concerns with protected_attributes, migrate this model to use strong parameters")
        super(*(args + @optional_attr_accessible))
      else
        super
      end
    end
  end
end
