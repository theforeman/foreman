module Foreman
  module Renderer
    module Source
      class Database < Foreman::Renderer::Source::Base
        def content
          @content ||= template.template
        end
      end
    end
  end
end
