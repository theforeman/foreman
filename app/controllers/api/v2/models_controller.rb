module Api
  module V2
    class ModelsController < V2::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/models/", N_("List all hardware models")
      param :search, String, :desc => N_("filter results")
      param :order, String, :desc => N_("sort results")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @models = Model.
          authorized(:view_models).
          search_for(*search_options).
          paginate(paginate_options)
      end

      api :GET, "/models/:id/", N_("Show a hardware model")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :model do
        param :model, Hash, :action_aware => true do
          param :name, String, :required => true
          param :info, String, :required => false
          param :vendor_class, String, :required => false
          param :hardware_model, String, :required => false
        end
      end

      api :POST, "/models/", N_("Create a hardware model")
      param_group :model, :as => :create

      def create
        @model = Model.new(params[:model])
        process_response @model.save
      end

      api :PUT, "/models/:id/", N_("Update a hardware model")
      param :id, String, :required => true
      param_group :model

      def update
        process_response @model.update_attributes(params[:model])
      end

      api :DELETE, "/models/:id/", N_("Delete a hardware model")
      param :id, String, :required => true

      def destroy
        process_response @model.destroy
      end
    end
  end
end
