module Api
  module V1
    class SettingsController < V1::BaseController
      before_filter :require_admin
      before_filter :find_resource, :only => %w{show update}

      api :GET, "/settings/", "List all settings."
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @settings = Setting.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/settings/:id/", "Show an setting."
      param :id, String, :required => true

      def show
      end

      api :PUT, "/settings/:id/", "Update a setting."
      param :id, String, :required => true
      param :setting, Hash, :required => true do
        param :value, String
      end

      def update
        process_response @setting.update_attributes(params[:setting])
      end

    end
  end
end
