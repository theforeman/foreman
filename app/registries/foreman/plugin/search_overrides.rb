module Foreman
  class Plugin
    module SearchOverrides
      attr_reader :search_overrides

      def initialize(*args)
        super
        @search_overrides = {}
      end

      # To add FiltersHelper#search_path override,
      # in lib/engine.rb, in plugin initialization block:
      # search_path_override("EngineModuleName") { |resource| ... }
      def search_path_override(engine_name, &blk)
        if block_given?
          @search_overrides[engine_name] = blk
        else
          Rails.logger.warn "Ignoring override of FiltersHelper#search_path_override for '#{engine_name}': no override block is present"
        end
      end
    end
  end
end
