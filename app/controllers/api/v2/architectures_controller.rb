module Api
  module V2
    class ArchitecturesController < V2::BaseController
      include Foreman::Controller::Parameters::Architecture

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy}

      api :GET, "/architectures/", N_("List all architectures")
      api :GET, "/operatingsystems/:operatingsystem_id/architectures", N_("List all architectures for operating system")
      param_group :search_and_pagination, ::Api::V2::BaseController
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      add_scoped_search_description_for(Architecture)

      def index
        @architectures = resource_scope_for_index
      end

      api :GET, "/architectures/:id/", N_("Show an architecture")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :architecture do
        param :architecture, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :operatingsystem_ids, Array, :desc => N_("Operating system IDs")
        end
      end

      api :POST, "/architectures/", N_("Create an architecture")
      param_group :architecture, :as => :create

      def create
        @architecture = Architecture.new(architecture_params)
        process_response @architecture.save
      end

      api :PUT, "/architectures/:id/", N_("Update an architecture")
      param :id, :identifier, :required => true
      param_group :architecture

      def update
        process_response @architecture.update(architecture_params)
      end

      api :DELETE, "/architectures/:id/", N_("Delete an architecture")
      param :id, :identifier, :required => true

      def destroy
        process_response @architecture.destroy
      end

      private

      def allowed_nested_id
        %w(operatingsystem_id)
      end
    end
  end
end
