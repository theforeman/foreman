module Foreman
  module Renderer
    module Scope
      module Macros
        module Inputs
          include Foreman::Renderer::Errors
          extend ApipieDSL::Module

          apipie :class, 'Macros related to template inputs' do
            name 'Template Inputs'
            sections only: %w[all reports provisioning jobs partition_tables]
          end

          apipie :method, 'Returns the value of template input' do
            required :name, String, desc: 'name of the template input'
            raises error: UndefinedInput, desc: 'when there is no input with such name defined for the current template'
            returns Object, desc: 'The value of template input'
            example 'input("Include Facts") #=> "yes"'
          end
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
