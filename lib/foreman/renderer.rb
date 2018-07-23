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

      def render_template_to_tempfile(template:, prefix:, host: nil, params: {}, variables: {}, options: {})
        file = ""
        source = get_source(template: template, host: host)
        scope = get_scope(host: host, params: params, variables: variables)
        Tempfile.open(prefix, Rails.root.join('tmp')) do |f|
          f.print render(source, scope)
          f.flush
          f.chmod options[:mode] if options[:mode]
          file = f
        end
        file
      end

      def get_source(klass: Foreman::Renderer::Source::Database, template:, **args)
        klass.new(template)
      end

      def get_scope(klass: Foreman::Renderer::Scope::Provisioning, host: nil, params: {}, variables: {})
        klass.new(host: host, params: params, variables: variables)
      end

      def renderer
        Setting[:safemode_render] ? Foreman::Renderer::SafeModeRenderer : Foreman::Renderer::UnsafeModeRenderer
      end

      delegate :render, to: :renderer
    end
  end
end
