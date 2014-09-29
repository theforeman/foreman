module Api
  module V2
    class ArchitecturesController < V2::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/architectures/", N_("List all architectures")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @architectures = Architecture.
          authorized(:view_architectures).
          includes(:operatingsystems).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/architectures/:id/", N_("Show an architecture")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :architecture do
        param :architecture, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :operatingsystem_ids, Array, :desc => N_("Operatingsystem IDs")
        end
      end

      api :POST, "/architectures/", N_("Create an architecture")
      param_group :architecture, :as => :create

      def create
        @architecture = Architecture.new(permitted_params('create'))
        process_response @architecture.save
      end

      api :PUT, "/architectures/:id/", N_("Update an architecture")
      param :id, :identifier, :required => true
      param_group :architecture

      def update
        process_response @architecture.update_attributes(permitted_params('update'))
      end

      api :DELETE, "/architectures/:id/", N_("Delete an architecture")
      param :id, :identifier, :required => true

      def destroy
        process_response @architecture.destroy
      end

      private

      def permitted_params(action)
        allow_params = ApipieParser.allowed_params('architectures', action, 'v2')
        params.require(:architecture).permit(*allow_params)
      end

    end
  end
end
