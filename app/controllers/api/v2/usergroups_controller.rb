module Api
  module V2
    class UsergroupsController < V2::BaseController

      before_filter :find_optional_nested_object
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/usergroups/", N_("List all user groups")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @usergroups = resource_scope_for_index
      end

      api :GET, "/usergroups/:id/", N_("Show a user group")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :usergroup do
        param :usergroup, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :user_ids, Array, :require => false
          param :usergroup_ids, Array, :require => false
          param :role_ids, Array, :require => false
        end
      end

      api :POST, "/usergroups/", N_("Create a user group")
      param_group :usergroup, :as => :create

      def create
        @usergroup = Usergroup.new(params[:usergroup])
        process_response @usergroup.save
      end

      api :PUT, "/usergroups/:id/", N_("Update a user group")
      param :id, String, :required => true
      param_group :usergroup

      def update
        process_response @usergroup.update_attributes(params[:usergroup])
      end

      api :DELETE, "/usergroups/:id/", N_("Delete a user group")
      param :id, String, :required => true

      def destroy
        process_response @usergroup.destroy
      end

      api :POST, "/usergroups/:usergroup_id/links/roles", N_("Add role to user group")
      api :POST, "/usergroups/:usergroup_id/links/users", N_("Add user to user group")
      param :usergroup_id, :identifier, :required => true
      param :users, Array, :required => false, :desc => N_("Array of IDs")
      param :usergroups, Array, :required => false, :desc => N_("Array of IDs")
      def add
      end

      api :DELETE, "/usergroups/:usergroup_id/links/roles/:id", N_("Remove role from user group")
      api :DELETE, "/usergroups/:usergroup_id/links/users/:id", N_("Remove user from user group")
      param :usergroup_id, :identifier, :required => true
      param :id, String, :required => true, :desc => N_("ID or comma-delimited list of IDs")
      def remove
      end

      private

      def allowed_nested_id
        %w(user_id usergroup_id)
      end

    end
  end
end
