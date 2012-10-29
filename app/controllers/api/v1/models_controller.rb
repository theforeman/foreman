module Api
  module V1
    class ModelsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/models/", "List all models."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @models = Model.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
      end

      api :GET, "/models/:id/", "Show a model."
      param :id, :identifier, :required => true
      def show
      end

      api :POST, "/models/", "Create an model."
      param :model, Hash, :required => true do
        param :name, String, :required => true
      end
      def create
        @model = Model.new(params[:model])
        process_response @model.save
      end

      api :PUT, "/models/:id/", "Update an model."
      param :id, String, :required => true
      param :model, Hash, :required => true do
        param :name, String
      end
      def update
        process_response @model.update_attributes(params[:model])
      end

      api :DELETE, "/models/:id/", "Delete an model."
      param :id, String, :required => true
      def destroy
        process_response @model.destroy
      end
    end
  end
end
