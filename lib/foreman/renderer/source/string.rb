module Foreman
  module Renderer
    module Source
      class String < Foreman::Renderer::Source::Base
        def initialize(name: 'Unnamed', content:)
          @name = name
          @content = content
        end

        attr_reader :name, :content
      end
    end
  end
end
