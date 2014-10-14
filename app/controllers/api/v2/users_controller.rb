module Api
  module V2
    class UsersController < V2::BaseController

      wrap_parameters User, :include => (User.attribute_names + ['password'])

      before_filter :find_resource, :only => %w{show update destroy}
      include Foreman::Controller::UsersMixin
      include Api::Version2
      include Api::TaxonomyScope
      before_filter :find_optional_nested_object
      before_filter :find_resource, :only => [:show, :update, :destroy]

      api :GET, "/users/", N_("List all users")
      api :GET, "/auth_source_ldaps/:auth_source_ldap_id/users", N_("List all users for LDAP authentication source")
      api :GET, "/usergroups/:usergroup_id/users", N_("List all users for user group")
      api :GET, "/roles/:role_id/users", N_("List all users for role")
      api :GET, "/locations/:location_id/users", N_("List all users for location")
      api :GET, "/organizations/:organization_id/users", N_("List all users for organization")
      param :auth_source_ldap_id, String, :desc => N_("ID of LDAP authentication source")
      param :usergroup_id, String, :desc => N_("ID of user group")
      param :role_id, String, :desc => N_("ID of role")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @users = resource_scope_for_index
      end

      api :GET, "/users/:id/", N_("Show a user")
      param :id, String, :required => true

      def show
      end

      def_param_group :user do
        param :user, Hash, :required => true, :action_aware => true do
          param :login, String, :required => true
          param :firstname, String, :required => false
          param :lastname, String, :required => false
          param :mail, String, :required => true
          param :admin, :bool, :required => false, :desc => N_("is an admin account")
          param :password, String, :required => true
          param :default_location_id, Integer if SETTINGS[:locations_enabled]
          param :default_organization_id, Integer if SETTINGS[:organizations_enabled]
          param :auth_source_id, Integer, :required => true
          param :timezone, String, :required => false
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/users/", N_("Create a user")
      description <<-DOC
        Adds role 'Anonymous' to the user by default
      DOC
      param_group :user, :as => :create

      def create
        if @user.save
          process_success
        else
          process_resource_error
        end
      end

      api :PUT, "/users/:id/", N_("Update a user")
      description <<-DOC
        Adds role 'Anonymous' to the user if it is not already present.
        Only another admin can change the admin account attribute.
      DOC
      param :id, String, :required => true
      param_group :user

      def update
        if @user.update_attributes(params[:user])
          update_sub_hostgroups_owners

          process_success
        else
          process_resource_error
        end
      end

      api :DELETE, "/users/:id/", N_("Delete a user")
      param :id, String, :required => true

      def destroy
        if @user == User.current
          deny_access N_("You are trying to delete your own account")
        else
          process_response @user.destroy
        end
      end

      api :POST, "/users/:user_id/links/roles", N_("Add role to user")
      api :POST, "/users/:user_id/links/usergroups", N_("Add user group to user")
      api :POST, "/users/:user_id/links/locations", N_("Add location to user")
      api :POST, "/users/:user_id/links/organizations", N_("Add organization to user")
      param :user_id, :identifier, :required => true
      param :roles, Array, :required => false, :desc => N_("Array of IDs")
      param :usergroups, Array, :required => false, :desc => N_("Array of IDs")
      param :locations, Array, :required => false, :desc => N_("Array of location IDs")
      param :organizations, Array, :required => false, :desc => N_("Array of organization IDs")
      def add
      end

      api :DELETE, "/users/:user_id/links/roles/:id", N_("Remove role from user")
      api :DELETE, "/users/:user_id/links/usergroups/:id", N_("Remove user group from user")
      api :DELETE, "/users/:user_id/links/locations/:id", N_("Remove location from user")
      api :DELETE, "/users/:user_id/links/organizations/:id", N_("Remove organization from user")
      param :user_id, :identifier, :required => true
      param :id, String, :required => true, :desc => N_("ID or comma-delimited list of IDs")
      def remove
      end

      private

      def allowed_nested_id
        %w(auth_source_ldap_id role_id location_id organization_id usergroup_id)
      end

    end
  end
end
