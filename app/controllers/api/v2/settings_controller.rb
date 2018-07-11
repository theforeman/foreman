module Api
  module V2
    class SettingsController < V2::BaseController
      before_action :find_resource, :only => %w{show update}

      api :GET, "/settings/", N_("List all settings")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Setting)

      def index
        @settings = resource_scope().live_descendants.search_for(*search_options).paginate(paginate_options)
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
        value = params[:setting][:value]
        if value.nil?
          render_error :custom_error, :status => :unprocessable_entity, :locals => { :message => _("No setting value provided.") }
        else
          process_response (@setting.parse_string_value(value) && @setting.save)
        end
      end
    end
  end
end
