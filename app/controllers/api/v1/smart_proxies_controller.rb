module Api
  module V1
    class SmartProxiesController < V1::BaseController
      resource_description do
        desc <<-DOC
        DOC
      end

      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :check_feature_type, :only => :index

      api :GET, "/smart_proxies/", "List of smart proxies"
      param :type, String, :required => false, :desc => ""
      def index
        @proxies = proxies_by_type(params[:type])
      end

      api :GET, "/smart_proxies/:id/", "Show a smart proxy."
      param :id, String, :required => true
      def show
      end

      api :POST, "/smart_proxies/", "Create a smart proxy."
      param :smart_proxy, Hash, :required => true do
        param :name, String, :required => true, :desc => "Smart proxy's name"
        param :url, String, :required => true, :desc => "Smart proxy's url"
      end
      def create
        @smart_proxy = SmartProxy.new(params[:smart_proxy])
        process_response @smart_proxy.save
      end

      api :PUT, "/smart_proxies/:id/", "Update a smart proxy."
      param :id, String, :required => true
      param :smart_proxy, Hash, :required => true do
        param :name, String, :required => false, :desc => "New name for the smart proxy"
        param :url, String, :required => false, :desc => "New url for the smart proxy"
      end
      def update
        process_response @smart_proxy.update_attributes(params[:smart_proxy])
      end

      api :DELETE, "/smart_proxies/:id/", "Delete a smart proxy."
      param :id, String, :required => true
      def destroy
        process_response @smart_proxy.destroy
      end

      private
      def proxies_by_type(type)
        return SmartProxy.try(type.downcase+"_proxies") if not type.nil?
        return SmartProxy.all
      end

      def check_feature_type
        return if params[:type].nil?

        allowed_types = SmartProxy::ProxyFeatures.map{|f| f.downcase}

        if not allowed_types.include? params[:type].downcase
          raise ArgumentError, "Invalid feature type. Select one of: #{SmartProxy::ProxyFeatures.join(", ")}."
        end
      end

    end
  end
end
