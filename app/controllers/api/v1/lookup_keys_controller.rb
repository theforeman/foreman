module Api
  module V1
    class LookupKeysController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/lookup_keys/", "List all lookup_keys."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      param :page,  String, :desc => "paginate results"
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
        param :puppetclass_id, :number
        param :default_value, String
        param :path, String
        param :description, String
        param :lookup_values_count, :number
      end
      def create
        @lookup_key = LookupKey.new(params[:lookup_key])
        process_response @lookup_key.save
      end

      api :PUT, "/lookup_keys/:id/", "Update a lookup key."
      param :id, :identifier, :required => true
      param :lookup_key, Hash, :required => true do
        param :key, String, :required => true
        param :puppetclass_id, :number
        param :default_value, String
        param :path, String
        param :description, String
        param :lookup_values_count, :number
      end
      def update
        process_response @lookup_key.update_attributes(params[:lookup_key])
      end

      api :DELETE, "/lookup_keys/:id/", "Delete a lookup key."
      param :id, :identifier, :required => true
      def destroy
        process_response @lookup_key.destroy
      end

    end
  end
end
