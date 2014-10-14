module Api
  module V2
    class BaseController < Api::BaseController
      include Api::Version2

      resource_description do
        api_version "v2"
        app_info N_("Foreman v2 is stable and recommended for use. You may use v2 by either passing 'version=2' in the Accept Header or using api/v2/ in the URL.")
      end

      def_param_group :pagination do
        param :page, String, :desc => N_("paginate results")
        param :per_page, String, :desc => N_("number of entries per request")
      end

      def_param_group :search_and_pagination do
        param :search, String, :desc => N_("filter results")
        param :order, String, :desc => N_("sort results")
        param_group :pagination, ::Api::V2::BaseController
      end

      def_param_group :taxonomies do
        param :location_ids, Array, :required => false, :desc => N_("REPLACE locations with given ids") if SETTINGS[:locations_enabled]
        param :organization_ids, Array, :required => false, :desc => N_("REPLACE organizations with given ids.") if SETTINGS[:organizations_enabled]
      end

      def_param_group :taxonomy_scope do
        param :location_id, Integer, :required => false, :desc => N_("Scope by locations") if SETTINGS[:locations_enabled]
        param :organization_id, Integer, :required => false, :desc => N_("Scope by organizations") if SETTINGS[:organizations_enabled]
      end

      before_filter :setup_has_many_params, :only => [:create, :update]
      before_filter :check_content_type
      # ensure include_root_in_json = false for V2 only
      around_filter :disable_json_root

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
        @total ||= resource_scope.try(:count).to_i
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
        @order ||=  params[:order].present? && (order_array = params[:order].split(' ')).any? ? (order_array[1] || 'ASC') : nil
      end

      def metadata_by
        @by ||= params[:order].present? && (order_array = params[:order].split(' ')).any? ? order_array[0] : nil
      end

      def metadata_page
        @page ||= params[:page].present? ? params[:page].to_i : 1
      end

      def metadata_per_page
        @per_page ||= params[:per_page].present? ? params[:per_page].to_i : Setting::General.entries_per_page
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
        hash_params.dup.each do |k,v|
          if v.kind_of?(Array)
            association_name_ids = "#{k.singularize}_ids"
            association_name_names = "#{k.singularize}_names"
            if resource_class.instance_methods.map(&:to_s).include?(association_name_ids) && v.any? && v.all? { |a| a.keys.include?("id") }
              params[model_name].merge!(association_name_ids => v.map { |a| a["id"] })
              params[model_name].except!(k)
            elsif resource_class.instance_methods.map(&:to_s).include?(association_name_names) && v.any? && v.all? { |a| a.keys.include?("name") }
              params[model_name].merge!(association_name_names => v.map { |a| a["name"] })
              params[model_name].except!(k)
            end
          end
        end if hash_params
      end

      def setup_has_many_params
        model_name = controller_name.singularize
        append_array_of_ids(params[model_name]) #wrapped params
        append_array_of_ids(params)             #unwrapped params
      end

      def check_content_type
        if (request.post? || request.put?) && request.content_type != "application/json"
          render_error(:unsupported_content_type, :status => 415)
        end
      end

      def render_error(error, options = { })
        render options.merge(:template => "api/v2/errors/#{error}",
                             :layout   => 'api/v2/layouts/error_layout')
      end

      private

      def disable_json_root
        # disable json root element
        ActiveRecord::Base.include_root_in_json = false
        yield
      ensure
        # re-enable json root element
        ActiveRecord::Base.include_root_in_json = true
      end

    end
  end
end
