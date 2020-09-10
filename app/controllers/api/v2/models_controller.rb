module Api
  module V2
    class ModelsController < V2::BaseController
      include Foreman::Controller::Parameters::Model

      before_action :find_resource, :only => %w{show update destroy}

      api :GET, "/models/", N_("List all hardware models")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Model)

      def index
        @models = resource_scope_for_index
      end

      api :GET, "/models/:id/", N_("Show a hardware model")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :model do
        param :model, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :info, String, :required => false
          param :vendor_class, String, :required => false
          param :hardware_model, String, :required => false
        end
      end

      api :POST, "/models/", N_("Create a hardware model")
      param_group :model, :as => :create

      def create
        @model = Model.new(model_params)
        process_response @model.save
      end

      api :PUT, "/models/:id/", N_("Update a hardware model")
      param :id, String, :required => true
      param_group :model

      def update
        process_response @model.update(model_params)
      end

      api :DELETE, "/models/:id/", N_("Delete a hardware model")
      param :id, String, :required => true

      def destroy
        process_response @model.destroy
      end
    end
  end
end
