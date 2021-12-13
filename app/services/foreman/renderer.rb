module Foreman
  module Renderer
    PREVIEW_MODE = 'preview'
    REAL_MODE = 'real'
    AVAILABLE_RENDERING_MODES = [PREVIEW_MODE, REAL_MODE]

    class << self
      attr_writer :config

      def config
        @config ||= Foreman::Renderer::Configuration.new
      end

      def configure
        yield config
      end

      def render_template_to_tempfile(template:, prefix:, host: nil, params: {}, variables: {}, options: {})
        file = ''
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

      def get_source(klass: nil, template:, **args)
        klass ||= Foreman::Renderer::Source::Database
        klass.new(template)
      end

      def get_scope(source: nil, klass: nil, host: nil, params: {}, variables: {}, mode: REAL_MODE, template: nil, template_input_values: {})
        source ||= get_source(template: template)
        klass ||= template&.default_render_scope_class || Foreman::Renderer::Scope::Provisioning
        klass.new(source: source, host: host, params: params, variables: variables, mode: mode, template_input_values: template_input_values)
      end

      def renderer
        Setting[:safemode_render] ? Foreman::Renderer::SafeModeRenderer : Foreman::Renderer::UnsafeModeRenderer
      end

      delegate :render, to: :renderer
    end
  end
end
