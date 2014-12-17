module Api
  module V1
    class LookupKeysController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :setup_search_options, :only => :index

      api :GET, "/lookup_keys/", "List all lookup_keys."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @lookup_keys = LookupKey.
          authorized(:view_external_variables).
          search_for(*search_options).paginate(paginate_options)
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
        @lookup_key = LookupKey.new(foreman_params)
        process_response @lookup_key.save
      end

      api :PUT, "/lookup_keys/:id/", "Update a lookup key."
      param :id, :identifier, :required => true
      param :lookup_key, Hash, :required => true do
        param :key, String
        param :puppetclass_id, :number
        param :default_value, String
        param :path, String
        param :description, String
        param :lookup_values_count, :number
      end

      def update
        process_response @lookup_key.update_attributes(foreman_params)
      end

      api :DELETE, "/lookup_keys/:id/", "Delete a lookup key."
      param :id, :identifier, :required => true

      def destroy
        process_response @lookup_key.destroy
      end
    end
  end
end
