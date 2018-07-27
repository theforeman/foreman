module Foreman
  module Renderer
    module Source
      class String
        def initialize(name: 'Unnamed', content:)
          @name = name
          @content = content
        end

        attr_reader :name, :content
      end
    end
  end
end
