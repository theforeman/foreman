module Api
  module V1
    class SmartProxiesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}
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
        @smart_proxy = SmartProxy.new(params[:smart_proxy])
        process_response @smart_proxy.save
      end

      api :PUT, "/smart_proxies/:id/", "Update a smart proxy."
      param :id, String, :required => true
      param :smart_proxy, Hash, :required => true do
        param :name, String
        param :url, String
      end

      def update
        process_response @smart_proxy.update_attributes(params[:smart_proxy])
      end

      api :DELETE, "/smart_proxies/:id/", "Delete a smart_proxy."
      param :id, String, :required => true

      def destroy
        process_response @smart_proxy.destroy
      end

      private
      def proxies_by_type(type)
        return SmartProxy.includes(:features).try(type.downcase+"_proxies") if not type.nil?
        return SmartProxy.includes(:features).all
      end

      def check_feature_type
        return if params[:type].nil?

        allowed_types = SmartProxy.name_map.keys

        if not allowed_types.include? params[:type].downcase
          raise ArgumentError, "Invalid feature type. Select one of: #{SmartProxy.name_map.keys.join(", ")}."
        end
      end

    end
  end
end
