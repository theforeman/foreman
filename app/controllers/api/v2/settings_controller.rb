module Api
  module V2
    class SettingsController < V2::BaseController
      before_filter :require_admin
      before_filter :find_resource, :only => %w{show update}

      api :GET, "/settings/", N_("List all settings")
      param :search, String, :desc => N_("filter results")
      param :order, String, :desc => N_("sort results")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @settings = Setting.search_for(*search_options).paginate(paginate_options)
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
