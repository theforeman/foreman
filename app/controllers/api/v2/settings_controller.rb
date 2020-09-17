module Api
  module V2
    class SettingsController < V2::BaseController
      before_action :find_resource, :only => %w{show update}

      api :GET, "/settings/", N_("List all settings")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Setting)

      def index
        @settings = resource_scope_for_index.live_descendants
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
        unless params[:setting]&.key?(:value)
          return render_error :custom_error, :status => :unprocessable_entity, :locals => { :message => _("No setting value provided.") }
        end
        value = params[:setting][:value]
        type = value.class.to_s.downcase
        type = "boolean" if %w[trueclass falseclass].include?(type)
        case type
        when "nilclass"
          @setting.value = value
          process_response @setting.save
        when "string"
          process_response (@setting.parse_string_value(value) && @setting.save)
        when @setting.settings_type
          @setting.value = value
          process_response @setting.save
        else
          render_error :custom_error, :status => :unprocessable_entity, :locals => { :message => _("expected a value of type %s") % @setting.settings_type}
        end
      end
    end
  end
end
