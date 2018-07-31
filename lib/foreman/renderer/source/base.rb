module Foreman
  module Renderer
    module Source
      class Base
        def initialize(template)
          @template = template
        end

        def name
          @name ||= template.try(:name) || 'Unnamed'
        end

        def content
          raise NotImplementedError
        end

        def find_snippet(name)
          raise NotImplementedError
        end

        attr_reader :template
      end
    end
  end
end
