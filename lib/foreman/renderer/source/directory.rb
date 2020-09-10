module Foreman
  module Renderer
    module Source
      class Directory < Database
        def find_snippet(snippet_name)
          snippets = ::Foreman::RenderTemplatesFromFolder.instance(source_directory: template.source_directory).snippets
          snippets.find { |snippet| snippet.name == snippet_name }
        end
      end
    end
  end
end
