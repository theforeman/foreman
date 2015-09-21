module Api
  module V1
    class ModelsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/models/", "List all models."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @models = Model.
          authorized(:view_models).
          search_for(*search_options).
          paginate(paginate_options)
      end

      api :GET, "/models/:id/", "Show a model."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/models/", "Create a model."
      param :model, Hash, :required => true do
        param :name, String, :required => true
        param :info, String, :required => false
        param :vendor_class, String, :required => false
        param :hardware_model, String, :required => false
      end

      def create
        @model = Model.new(foreman_params)
        process_response @model.save
      end

      api :PUT, "/models/:id/", "Update a model."
      param :id, String, :required => true
      param :model, Hash, :required => true do
        param :name, String
        param :info, String
        param :vendor_class, String
        param :hardware_model, String
      end

      def update
        process_response @model.update_attributes(foreman_params)
      end

      api :DELETE, "/models/:id/", "Delete a model."
      param :id, String, :required => true

      def destroy
        process_response @model.destroy
      end
    end
  end
end
