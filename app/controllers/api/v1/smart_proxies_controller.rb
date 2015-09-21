module Api
  module V1
    class SmartProxiesController < V1::BaseController
      include Api::ImportPuppetclassesCommonController
      before_filter :find_resource, :only => %w{show update destroy refresh}
      before_filter :check_feature_type, :only => :index

      api :GET, "/smart_proxies/", "List all smart_proxies."
      param :type, String, :desc => "filter by type"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @smart_proxies = proxies_by_type(params[:type]).paginate(paginate_options)
      end

      api :GET, "/smart_proxies/:id/", "Show a smart proxy."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/smart_proxies/", "Create a smart proxy."
      param :smart_proxy, Hash, :required => true do
        param :name, String, :required => true
        param :url, String, :required => true
      end

      def create
        @smart_proxy = SmartProxy.new(foreman_params)
        process_response @smart_proxy.save
      end

      api :PUT, "/smart_proxies/:id/", "Update a smart proxy."
      param :id, String, :required => true
      param :smart_proxy, Hash, :required => true do
        param :name, String
        param :url, String
      end

      def update
        process_response @smart_proxy.update_attributes(foreman_params)
      end

      api :DELETE, "/smart_proxies/:id/", "Delete a smart_proxy."
      param :id, String, :required => true

      def destroy
        process_response @smart_proxy.destroy
      end

      api :PUT, "/smart_proxies/:id/refresh", "Refresh smart proxy features"
      param :id, String, :required => true

      def refresh
        process_response @smart_proxy.refresh.blank? && @smart_proxy.save
      end

      private

      def action_permission
        case params[:action]
        when 'refresh'
          :edit
        else
          super
        end
      end

      def proxies_by_type(type)
        return SmartProxy.authorized(:view_smart_proxies).includes(:features).with_features(type) if type.present?
        SmartProxy.authorized(:view_smart_proxies).includes(:features).to_a
      end

      def check_feature_type
        return if params[:type].nil?

        allowed_types = Feature.name_map.keys

        if not allowed_types.include? params[:type].downcase
          raise ArgumentError, "Invalid feature type. Select one of: #{allowed_types.join(", ")}."
        end
      end
    end
  end
end
