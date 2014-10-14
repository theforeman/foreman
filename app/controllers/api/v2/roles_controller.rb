module Api
  module V2
    class RolesController < V2::BaseController

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

      api :POST, "/roles/:role_id/links/users", N_("Add user to role")
      api :POST, "/roles/:role_id/links/usergroups", N_("Add user to role")
      param :role_id, :identifier, :required => true
      param :users, Array, :required => false, :desc => N_("Array of IDs")
      param :usergroups, Array, :required => false, :desc => N_("Array of IDs")
      def add
      end

      api :DELETE, "/roles/:role_id/links/users/:id", N_("Remove user from role")
      api :DELETE, "/roles/:role_id/links/usergroups/:id", N_("Remove usergroup from role")
      param :role_id, :identifier, :required => true
      param :id, String, :required => true, :desc => N_("ID or comma-delimited list of IDs")
      def remove
      end

      private

      def allowed_nested_id
        %w(user_id)
      end

    end
  end
end
