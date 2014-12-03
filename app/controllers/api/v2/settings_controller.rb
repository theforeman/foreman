module Api
  module V2
    class SettingsController < V2::BaseController
      before_filter :require_admin
      before_filter :find_resource, :only => %w{show update}

      api :GET, "/settings/", N_("List all settings")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @settings = resource_scope_for_index
      end

      api :GET, "/settings/:id/", N_("Show a setting")
      param :id, String, :required => true

      def show
      end

      api :PUT, "/settings/:id/", N_("Update a setting")
      param :id, String, :required => true
      param :setting, Hash, :required => true do
        param :value, String
      end

      def update
        process_response (@setting.parse_string_value(params[:setting][:value]) && @setting.save)
      end

    end
  end
end
