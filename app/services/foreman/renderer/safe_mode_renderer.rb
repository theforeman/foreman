module Foreman
  module Renderer
    class SafeModeRenderer < BaseRenderer
      def render
        box = Safemode::Box.new(scope, allowed_helpers, source_name)
        erb = ERB.new(source_content, trim_mode: '-')
        box.eval(erb.src, allowed_variables)
      rescue ::Racc::ParseError => e
        new_e = SyntaxError.new(name: source_name, message: e.message)
        new_e.set_backtrace(e.backtrace)
        raise new_e
      end

      delegate :allowed_variables, :allowed_helpers, to: :scope
    end
  end
end
