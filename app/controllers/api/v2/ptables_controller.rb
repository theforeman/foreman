module Api
  module V2
    class PtablesController < V2::BaseController

      before_filter :find_optional_nested_object
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/ptables/", N_("List all partition tables")
      api :GET, "/operatingsystems/:operatingsystem_id/ptables", N_("List all partition tables for an operating system")
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @ptables = resource_scope_for_index
      end

      api :GET, "/ptables/:id/", N_("Show a partition table")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :ptable do
        param :ptable, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :layout, String, :required => true
          param :os_family, String, :required => false
        end
      end

      api :POST, "/ptables/", N_("Create a partition table")
      param_group :ptable, :as => :create

      def create
        @ptable = Ptable.new(params[:ptable])
        process_response @ptable.save
      end

      api :PUT, "/ptables/:id/", N_("Update a partition table")
      param :id, String, :required => true
      param_group :ptable

      def update
        process_response @ptable.update_attributes(params[:ptable])
      end

      api :DELETE, "/ptables/:id/", N_("Delete a partition table")
      param :id, String, :required => true

      def destroy
        process_response @ptable.destroy
      end

      private

      def allowed_nested_id
        %w(operatingsystem_id)
      end

    end
  end
end
