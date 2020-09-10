module Api
  module V2
    class UsergroupsController < V2::BaseController
      include Foreman::Controller::Parameters::Usergroup

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy}

      api :GET, "/usergroups/", N_("List all user groups")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Usergroup)

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
          param :admin, :bool, :required => false, :desc => N_("is an admin user group")
          param :user_ids, Array, :require => false
          param :usergroup_ids, Array, :require => false
          param :role_ids, Array, :require => false
        end
      end

      api :POST, "/usergroups/", N_("Create a user group")
      param_group :usergroup, :as => :create

      def create
        @usergroup = Usergroup.new(usergroup_params)
        process_response @usergroup.save
      end

      api :PUT, "/usergroups/:id/", N_("Update a user group")
      description <<-DOC
        User groups linked to external groups (LDAP) are automatically synced
        with these groups on update. Remember this synchronization will remove
        any LDAP users manually added to the Foreman user group. Only LDAP
        users in the external groups will remain. Internal users can be added
        or removed freely.
      DOC
      param :id, String, :required => true
      param_group :usergroup

      def update
        process_response @usergroup.update(usergroup_params)
      end

      api :DELETE, "/usergroups/:id/", N_("Delete a user group")
      param :id, String, :required => true

      def destroy
        process_response @usergroup.destroy
      end

      rescue_from ::Foreman::CyclicGraphException do |error|
        @usergroup.errors.add :usergroups, error.message
        process_resource_error
      end

      private

      def allowed_nested_id
        %w(user_id usergroup_id)
      end
    end
  end
end
