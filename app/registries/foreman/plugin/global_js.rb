module Foreman
  class Plugin
    module GlobalJs
      attr_reader :global_js_files

      def initialize(id)
        super
        @global_js_files = []
      end

      def register_global_js_file(file)
        @global_js_files << file
      end
    end
  end
end
