module Foreman
  module Renderer
    module Source
      class Database < Foreman::Renderer::Source::Base
        def content
          @content ||= template.template
        end

        def find_snippet(name)
          ::Template.where(name: name, snippet: true).first
        end
      end
    end
  end
end
