module Api
  module V2
    class PluginsController < BaseController
      api :GET, "/plugins", N_("List installed plugins")
      def index
        @plugins = Foreman::Plugin.all
        @total = @plugins.try(:count).to_i
      end
    end
  end
end
