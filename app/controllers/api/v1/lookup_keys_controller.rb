module Api
  module V1
    class LookupKeysController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/lookup_keys/", "List all lookup_keys."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @lookup_keys = LookupKey.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
      end

      api :GET, "/lookup_keys/:id/", "Show a lookup key."
      param :id, :identifier, :required => true
      def show
      end

      api :POST, "/lookup_keys/", "Create a lookup key."
      param :lookup_key, Hash, :required => true do
        param :key, String, :required => true
        param :puppetclass_id, String, :required => false
        param :default_value, String, :required => false
        param :path, String, :required => false
        param :description, String, :required => false
        param :lookup_values_count, String, :required => false
      end
      def create
        @lookup_key = LookupKey.new(params[:lookup_key])
        process_response @lookup_key.save
      end

      api :PUT, "/lookup_keys/:id/", "Update a lookup key."
      param :id, String, :required => true
      param :lookup_key, Hash, :required => true do
        param :key, String, :required => true
        param :puppetclass_id, String, :required => false
        param :default_value, String, :required => false
        param :path, String, :required => false
        param :description, String, :required => false
        param :lookup_values_count, String, :required => false
      end
      def update
        process_response @lookup_key.update_attributes(params[:lookup_key])
      end

      api :DELETE, "/lookup_keys/:id/", "Delete a lookup key."
      param :id, String, :required => true
      def destroy
        process_response @lookup_key.destroy
      end

    end
  end
end
