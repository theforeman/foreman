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
        source = subjects[:source] || Foreman::Renderer::Source::Database.new(template)

        scope = subjects[:scope] || Foreman::Renderer::Scope::Provisioning.new(host: subjects[:host],
                                                                               params: params,
                                                                               variables: variables)
        renderer.render(source, scope)
      end

      def render_template_to_tempfile(template, prefix, options = {}, subjects: {}, params: {}, variables: {})
        file = ""
        Tempfile.open(prefix, Rails.root.join('tmp')) do |f|
          f.print(render_template(template: template, subjects: subjects, params: params, variables: variables))
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
