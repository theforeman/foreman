module Api
  module V2
    class PluginsController < BaseController

      api :GET, '/plugins', 'List of installed plugins'
      def index
        @plugins = Foreman::Plugin.all
      end

    end
  end
end
