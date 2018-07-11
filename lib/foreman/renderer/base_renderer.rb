module Foreman
  module Renderer
    class BaseRenderer
      include Foreman::Renderer::Errors

      def initialize(source, scope)
        @source = source
        @scope = scope
        @scope.instance_variable_set('@template_name', source_name)
      end

      def render
        raise NotImplementedError
      end

      def self.render(source, scope)
        new(source, scope).render
      end

      private

      attr_reader :source, :scope
      delegate :name, :content, to: :source, prefix: true
    end
  end
end
