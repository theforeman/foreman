module Api
  module V2
    class RolesController < V2::BaseController

      wrap_parameters :role, :include => (Role.attribute_names + ['user_ids', 'usergroup_ids'])

      include Api::Version2

      before_filter :find_optional_nested_object
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/roles/", N_("List all roles")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @roles = resource_scope_for_index
      end

      api :GET, "/roles/:id/", N_("Show a role")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :role do
        param :role, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :user_ids, Array, :desc => (N_("Array of user IDs to associate.") + DESC_WARNING_IDS)
          param :usergroup_ids, Array, :desc => (N_("Array of user group IDs to associate.") + DESC_WARNING_IDS)
        end
      end

      api :POST, "/roles/", N_("Create a role")
      param_group :role, :as => :create

      def create
        @role = Role.new(params[:role])
        process_response @role.save
      end

      api :PUT, "/roles/:id/", N_("Update a role")
      param :id, String, :required => true
      param_group :role

      def update
        process_response @role.update_attributes(params[:role])
      end

      api :DELETE, "/roles/:id/", N_("Delete a role")
      param :id, String, :required => true

      def destroy
        process_response @role.destroy
      end

      private

      def allowed_nested_id
        %w(user_id)
      end
    end
  end
end
