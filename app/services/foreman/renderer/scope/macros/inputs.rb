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

          apipie :method, 'Find and returns resource object from the template input value' do
            required :name, String, desc: 'name of the template input'
            raises error: UndefinedInput, desc: 'when there is no input with such name defined for the current template'
            raises error: WrongInputValueType, desc: 'when the input value type is not "resource"'
            returns Object, desc: 'The resource object'
            example 'input_resource("hostgroup") #=> "ActiveRecord object"'
          end
          def input_resource(name)
            @input = template.template_inputs&.find_by_name(name)

            raise UndefinedInput.new(s: name) unless @input
            raise WrongInputValueType.new(name: name, type: @input.value_type) if @input.value_type != 'resource'

            return resource_klass.new if preview?
            find_resource
          end

          private

          def resource_klass
            @input.resource_type.constantize
          rescue NameError
            raise UnknownResource.new(klass: @input.resource_type)
          end

          def resource_permission
            "view_#{@input.resource_type.demodulize.underscore.pluralize}".to_sym
          end

          def find_resource
            resource_klass.authorized(resource_permission)
                          .find(@input.value(self))
          end
        end
      end
    end
  end
end
