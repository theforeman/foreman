module Foreman
  module Renderer
    class BaseRenderer
      include Foreman::Renderer::Errors

      def initialize(source, scope)
        @source = source
        @scope = scope

        @scope.renderer = self.class
      end

      def render
        raise NotImplementedError
      end

      def self.render(source, scope)
        renderer_instance = new(source, scope)
        result = renderer_instance.render

        digest = Digest::SHA256.hexdigest(result)
        if !scope.preview? && source.template&.log_render_results?
          Foreman::Logging.blob("Unattended render of '#{source.name}' = '#{digest}'", result,
            template_digest: digest,
            template_name: source.name,
            template_host_name: scope.host.try(:name),
            template_host_id: scope.host.try(:id))
        end

        if !scope.preview? && source.template&.render_statuses_enabled?
          Foreman::Renderer::RenderStatusService.success(
            host: scope.host,
            provisioning_template: source.template,
            safemode: safemode
          )
        end

        result
      rescue StandardError => e
        if !scope.preview? && source.template&.render_statuses_enabled?
          Foreman::Renderer::RenderStatusService.error(
            host: scope.host,
            provisioning_template: source.template,
            safemode: safemode
          )
        end

        raise e
      end

      def self.safemode
        self::SAFEMODE
      rescue NameError
        raise NotImplementedError
      end

      private

      attr_reader :source, :scope
      delegate :name, :content, to: :source, prefix: true
    end
  end
end
