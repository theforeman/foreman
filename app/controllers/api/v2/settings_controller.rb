module Api
  module V2
    class SettingsController < V2::BaseController
      before_action :find_resource, :only => %w{show update}

      def_param_group :setting_params do
        property :id, Integer, desc: N_('OBSOLATED: id of the setting record, doesn\'t need to be set in the future')
        property :name, String, desc: N_('Setting unique name')
        property :full_name, String, desc: N_('Setting full user readable name')
        property :category, String, desc: N_('The category of setting')
        property :category_name, String, desc: N_('The human readable name of settings category')
        property :settings_type, String, desc: N_('Value type, that the setting accepts')
        property :description, String, desc: N_('Describes the purpose of the setting')
        property :default, String, desc: N_('Default value for the setting')
        property :value, String, desc: N_('Setting current value. If this setting is encypted, the value will not be returned')
        property :readonly, [true, false], desc: N_('Is this setting readonly?')
        property :encrypted, [true, false], desc: N_('Is this setting encrypted?')
        property :config_file, String, desc: N_('If this setting needs to be changed in file, it will have the file path.')
        property :select_values, Array, desc: N_('If this setting has list of possible values, this includes the list of the values.')
        property :created_at, Time, desc: N_('DEPRECATED: this will be always application install time and dropped in the future release.')
        property :updated_at, Time, desc: N_('Last updated. NOTE: this will be reset to application install time, when setting is reset to default value.')
      end

      api :GET, "/settings/", N_("List all settings")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Setting)
      returns desc: N_('List of all settings') do
        property :results, Array
      end

      def index
        @settings = resource_scope_for_index.live_descendants
      end

      api :GET, "/settings/:id/", N_("Show a setting")
      param :id, String, required: true
      returns :setting_params, desc: N_('Information about the setting')

      def show
      end

      api :PUT, "/settings/:id/", N_("Update a setting")
      param :id, String, :required => true
      param :setting, Hash, :required => true do
        param :value, String
      end
      returns :setting_params, desc: N_('Information about the updated setting')

      def update
        value = params[:setting][:value]
        type = value.class.to_s.downcase
        if type == "trueclass" || type == "falseclass"
          type = "boolean"
        end
        case type
        when "nilclass"
          render_error :custom_error, :status => :unprocessable_entity, :locals => { :message => _("No setting value provided.") }
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
