module Foreman
  module Renderer
    module Scope
      module Macros
        module SnippetRendering
          def snippet_if_exists(name, options = {})
            snippet(name, { silent: true }, variables: options[:variables])
          end

          # provide embedded snippets support as simple erb templates
          def snippets(file, options = {})
            if ::Template.where(:name => file, :snippet => true).empty?
              render :partial => "unattended/snippets/#{file}"
            else
              snippet(file.gsub(/^_/, ""), options)
            end
          end

          def snippet(name, options = {}, variables: {})
            if (template = ::Template.where(:name => name, :snippet => true).first)
              begin
                snippet_variables = variables.merge(options[:variables] || {})
                source = Foreman::Renderer.get_source(template: template, host: @host)
                scope = Foreman::Renderer.get_scope(host: @host, variables: snippet_variables)
                return Foreman::Renderer.render(source, scope)
              rescue ::Foreman::Exception
                raise
              rescue StandardError => exc
                e = ::Foreman::Exception.new(N_("The snippet '%{name}' threw an error: %{exc}"), { :name => name, :exc => exc })
                e.set_backtrace exc.backtrace
                raise e
              end
            else
              raise "The specified snippet '#{name}' does not exist, or is not a snippet." unless options[:silent]
            end
          end
        end
      end
    end
  end
end
