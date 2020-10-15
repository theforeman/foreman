module Api
  module V2
    class BaseController < Api::BaseController
      include Api::Version2
      include Foreman::Controller::Authorize

      resource_description do
        api_version "v2"
        app_info N_("Foreman API v2 is currently the default API version.")
        param :location_id, Integer, :required => false, :desc => N_("Set the current location context for the request")
        param :organization_id, Integer, :required => false, :desc => N_("Set the current organization context for the request")
      end

      def_param_group :pagination do
        param :page, :number, :desc => N_("Page number, starting at 1")
        param :per_page, /\A([1-9]\d*|all)\Z$/, :desc => N_("Number of results per page to return, 'all' to return all results")
      end

      def_param_group :search_and_pagination do
        param :search, String, :desc => N_("filter results")
        param :order, String, :desc => N_("Sort field and order, eg. ‘id DESC’")
        param_group :pagination, ::Api::V2::BaseController
      end

      def_param_group :taxonomies do
        param :location_ids, Array, :required => false, :desc => N_("REPLACE locations with given ids")
        param :organization_ids, Array, :required => false, :desc => N_("REPLACE organizations with given ids.")
      end

      def_param_group :taxonomy_scope do
        param :location_id, Integer, :required => false, :desc => N_("Scope by locations")
        param :organization_id, Integer, :required => false, :desc => N_("Scope by organizations")
      end

      def_param_group :template_import_options do
        param :options, Hash, :required => false do
          param :force, :bool, :allow_nil => true, :desc => N_('use if you want update locked templates')
          param :associate, ['new', 'always', 'never'], :allow_nil => true, :desc => N_('determines when the template should associate objects based on metadata, new means only when new template is being created, always means both for new and existing template which is only being updated, never ignores metadata')
          param :lock, :bool, :allow_nil => true, :desc => N_('lock imported templates (false by default)')
          param :default, :bool, :allow_nil => true, :desc => N_('makes the template default meaning it will be automatically associated with newly created organizations and locations (false by default)')
        end
      end

      before_action :setup_has_many_params, :only => [:create, :update]
      before_action :check_media_type

      layout 'api/v2/layouts/index_layout', :only => :index

      helper_method :root_node_name, :metadata_total, :metadata_subtotal, :metadata_search,
        :metadata_order, :metadata_by, :metadata_page, :metadata_per_page
      def root_node_name
        @root_node_name ||= if Rabl.configuration.use_controller_name_as_json_root
                              controller_name.split('/').last
                            elsif params['root_name'].present?
                              params['root_name']
                            else
                              Rabl.configuration.json_root_default_name
                            end
      end

      def metadata_total
        @total ||= resource_scope.try(:size).to_i
      end

      def metadata_subtotal
        if params[:search].present?
          @subtotal ||= instance_variable_get("@#{controller_name}").try(:count).to_i
        else
          @subtotal ||= metadata_total
        end
      end

      def metadata_search
        @search ||= params[:search]
      end

      def metadata_order
        @order ||=  (params[:order].present? && (order_array = params[:order].split(' ')).any?) ? (order_array[1] || 'ASC') : nil
      end

      def metadata_by
        @by ||= (params[:order].present? && (order_array = params[:order].split(' ')).any?) ? order_array[0] : nil
      end

      def metadata_page
        @page ||= params[:page].present? ? params[:page].to_i : 1
      end

      def metadata_per_page
        @per_page ||= Setting[:entries_per_page] if params[:per_page].empty?
        @per_page ||= params[:per_page] == 'all' ? metadata_total : params[:per_page].to_i
      end

      # For the purpose of ADDING/REMOVING associations in CHILD node on POST/PUT payload
      # This method adds a Rails magic method ({association}_ids) based on the CHILD node ARRAY of OBJECTS
      # Example: PUT api/operatingsystems/24
      # {
      #   "operatingsystem": {
      #     "id": 24,
      #     "name": "CentOs",
      #     "architectures": [
      #         {
      #             "name": "i386",
      #             "id": 2
      #         },
      #         {
      #             "name": "x86_64",
      #             "id": 1
      #         }
      #      ]
      #     }
      #  }
      #
      #  Rails magic method (ex. architecture_ids) is added to params hash based on CHILD node (architectures)
      #
      #   "operatingsystem": {
      #     "id": 24,
      #     "name": "CentOs",
      #     "architecture_ids": [1,2]
      #    }
      #
      def append_array_of_ids(hash_params)
        model_name = controller_name.singularize
        hash_params&.dup&.each do |k, v|
          if v.is_a?(Array)
            association_name_ids = "#{k.singularize}_ids"
            association_name_names = "#{k.singularize}_names"
            if resource_class.instance_methods.map(&:to_s).include?(association_name_ids) && v.any? && v.all? { |a| a.key?("id") }
              params[model_name][association_name_ids] = v.map { |a| a["id"] }
              params[model_name].delete(k)
            elsif resource_class.instance_methods.map(&:to_s).include?(association_name_names) && v.any? && v.all? { |a| a.key?("name") }
              params[model_name][association_name_names] = v.map { |a| a["name"] }
              params[model_name].delete(k)
            end
          end
        end
      end

      def setup_has_many_params
        model_name = controller_name.singularize
        append_array_of_ids(params[model_name]) # wrapped params
        append_array_of_ids(params)             # unwrapped params
      end

      def self.skip_before_action(*names)
        names = names.map do |n|
          if n == :check_content_type
            Foreman::Deprecation.deprecation_warning('2.3', '#check_content_type is renamed to #check_media_type')
            :check_media_type
          else
            n
          end
        end
        super(*names)
      end

      def check_content_type
        Foreman::Deprecation.deprecation_warning('2.3', '#check_content_type is renamed to #check_media_type')
        check_media_type
      end

      def check_media_type
        if (request.post? || request.put?) && request.media_type != "application/json"
          render_error(:unsupported_media_type, :status => :unsupported_media_type)
        end
      end

      def render_error(error, options = { })
        options = set_error_details(error, options)
        render options.merge(:template => "api/v2/errors/#{error}",
                             :layout   => 'api/v2/layouts/error_layout')
      end
    end
  end
end
