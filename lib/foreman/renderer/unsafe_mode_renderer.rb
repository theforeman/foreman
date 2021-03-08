module Foreman
  module Renderer
    class UnsafeModeRenderer < BaseRenderer
      extend Foreman::Observable

      def self.render(source, scope)
        result = super

        if !scope.preview? && source.template.is_a?(ProvisioningTemplate) && !source.template&.snippet?
          trigger_hook(:unsafemode_rendered, payload: { host_id: scope.host&.id, template_id: source.template&.id })
        end

        result
      rescue StandardError => e
        if !scope.preview? && source.template.is_a?(ProvisioningTemplate) && !source.template&.snippet?
          trigger_hook(:unsafemode_rendering_error, payload: { host_id: scope.host&.id, template_id: source.template&.id })
        end

        raise e
      end

      def render
        erb = ERB.new(source_content, nil, '-')
        erb.location = source_name, 0
        erb.result(get_binding)
      rescue ::SyntaxError => e
        new_e = SyntaxError.new(name: source_name, message: e.message)
        new_e.set_backtrace(e.backtrace)
        raise new_e
      end

      delegate :get_binding, to: :scope
    end
  end
end
