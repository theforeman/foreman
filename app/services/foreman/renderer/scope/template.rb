module Foreman
  module Renderer
    module Scope
      class Template < Foreman::Renderer::Scope::Base
        include Foreman::Renderer::Scope::Macros::Inputs
        attr_reader :template_input_values

        def initialize(template_input_values: {}, **params)
          super(params)
          @template_input_values = template_input_values
        end
      end
    end
  end
end
