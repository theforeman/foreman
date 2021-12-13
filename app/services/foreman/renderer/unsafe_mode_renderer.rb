module Foreman
  module Renderer
    class UnsafeModeRenderer < BaseRenderer
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
