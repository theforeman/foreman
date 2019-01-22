module Foreman
  module Renderer
    module Source
      class String < Foreman::Renderer::Source::Base
        def initialize(name: 'Unnamed', content:, available_snippets: [])
          @name = name
          @content = content
          @available_snippets = available_snippets
        end

        def find_snippet(name)
          available_snippets.find { |snippet| snippet.name == name }
        end

        attr_reader :name, :content, :available_snippets
      end
    end
  end
end
