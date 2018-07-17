module Foreman
  module Renderer
    module Scope
      module Macros
        module Inputs
          include Foreman::Renderer::Errors

          def input(name)
            input = template.template_inputs&.find_by_name(name)
            if input
              preview? ? input.preview(self) : input.value(self)
            else
              raise UndefinedInput.new(s: name)
            end
          end
        end
      end
    end
  end
end
