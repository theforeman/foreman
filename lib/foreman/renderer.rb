module Foreman
  module Renderer
    class << self
      attr_writer :config

      def config
        @config ||= Foreman::Renderer::Configuration.new
      end

      def configure
        yield config
      end

      def render_template(template: nil, subjects: {}, params: {}, variables: {})
        source = if subjects[:source]
                   subjects[:source]
                 else
                   klass = params.fetch(:source_class, Foreman::Renderer::Source::Database)
                   klass.new(template)
                 end

        scope = if subjects[:scope]
                  subjects[:scope]
                else
                  klass = params.fetch(:scope_class, Foreman::Renderer::Scope::Provisioning)
                  klass.new(subjects[:host], params: params.merge(allowed_variables: variables.keys), variables: variables)
                end

        renderer.render(source, scope)
      end

      def render_template_to_tempfile(template, prefix, options = {})
        file = ""
        Tempfile.open(prefix, Rails.root.join('tmp')) do |f|
          f.print(render_template(template: template))
          f.flush
          f.chmod options[:mode] if options[:mode]
          file = f
        end
        file
      end

      def renderer
        Setting[:safemode_render] ? Foreman::Renderer::SafeModeRenderer : Foreman::Renderer::UnsafeModeRenderer
      end
    end
  end
end
