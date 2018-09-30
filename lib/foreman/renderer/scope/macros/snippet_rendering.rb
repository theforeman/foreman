module Foreman
  module Renderer
    module Scope
      module Macros
        module SnippetRendering
          def snippet_if_exists(name, options = {})
            snippet(name, { silent: true }, variables: options[:variables] || {})
          end

          def snippets(file, options = {})
            Foreman::Deprecation.deprecation_warning('1.22', 'The snippets template macro is deprecated. Please use snippet instead.')
            snippet(file.gsub(/^_/, ''), options)
          end

          def snippet(name, options = {}, variables: {})
            template = source.find_snippet(name)
            unless template
              raise "The specified snippet '#{name}' does not exist, or is not a snippet." unless options[:silent]
              return
            end

            begin
              snippet_variables = variables.merge(options[:variables] || {})
              template.render(host: host, variables: snippet_variables, mode: mode)
            rescue ::Foreman::Exception => e
              Foreman::Logging.exception('Error while rendering a snippet', e)
              raise
            rescue StandardError => exc
              e = ::Foreman::Exception.new(N_("The snippet '%{name}' threw an error: %{exc}"), { :name => name, :exc => exc })
              e.set_backtrace exc.backtrace
              raise e
            end
          end
        end
      end
    end
  end
end
