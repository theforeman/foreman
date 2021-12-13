module Foreman
  module Renderer
    module Scope
      module Macros
        module SnippetRendering
          extend ApipieDSL::Module

          apipie :class, 'Snippets related macros' do
            name 'Snippet'
            sections only: %w[all provisioning]
          end

          apipie :method, 'Renders a snippet if it exists in template source, e.g. database' do
            desc 'Same to snippet but does not fail and continues the main rendering if the given snippet was not found'
            required :name, String, desc: 'Name of the snippet template to render'
            optional :options, Hash, desc: 'The only supported key is +variables+, which can contain a Hash. Every key of such Hash will be registered as instance variable, e.g. key +enable_ntp+ will be available as +@enable_ntp+',
                                     default: {}
            returns String, desc: 'evaluated ERB of the snippet'
            raises error: Foreman::Exception, desc: 'in case the snippet raised exception during rendering.'
            example "snippet_if_exist('motd') # => 'Hello world'"
            example "snippet_if_exist('ntp_server', { :variables => { :enable_ntp => true } }) # => '...'"
            see 'snippet', description: 'Snippet#snippet', scope: Foreman::Renderer::Scope::Macros::SnippetRendering
          end
          def snippet_if_exists(name, options = {})
            snippet(name, { silent: true }, variables: options[:variables] || {})
          end

          apipie :method, 'Renders a string, which is a result of rendering other template snippet' do
            desc 'Main templates can share common logic in so call snippets. For example puppet agent
              configuration is done the same way in Kickstart and Preseed templates, hence is extracted to puppet_setup
              snippet. Using +snippet+ macro, this can be rendered into a main template. Snippets can render other
              snippets. Also same snippet can be rendered multiple times. This can be useful if the snippet is
              parametrized using variables.
              The snippet rendering happens in the same context as the main template rendering, meaning all instance
              variables and macros are available in that snippet. Variables passed to this snippet are available
              only during the snippet rendering.'
            required :name, String, desc: 'Name of the snippet template to render'
            optional :options, Hash, desc: 'Rendering options, the only supported option is +variables+ which can also be set by specific keyword argument',
                                     default: {}
            optional :variables, Hash, desc: 'Every key will be registered as instance variable, e.g. key +enable_ntp+ will be available as +@enable_ntp+',
                                       default: {}
            returns String, desc: 'evaluated ERB of the snippet'
            raises error: StandardError, desc: 'in case the snippet was not found in the current template source, e.g. a database.'
            raises error: Foreman::Exception, desc: 'in case the snippet raised exception during rendering.'
            example "snippet('motd') # => 'Hello world'"
            example "snippet('ntp_server', variables: { :enable_ntp => true) } # => '...'"
          end
          def snippet(name, options = {}, variables: {})
            template = source.find_snippet(name)
            unless template
              raise "The specified snippet '#{name}' does not exist, or is not a snippet." unless options[:silent]
              return
            end

            begin
              snippet_variables = variables_keys.index_with { |key| instance_variable_get("@#{key}") }
                                                .symbolize_keys
                                                .merge(variables)
                                                .merge(options[:variables] || {})
              template.render(renderer: renderer, host: host, variables: snippet_variables, params: params, mode: mode, source_klass: source&.class)
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
