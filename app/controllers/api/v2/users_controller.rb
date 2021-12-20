module Api
  module V2
    class UsersController < V2::BaseController
      before_action :find_resource, :only => %w{show update destroy}
      # find_resource needs to be defined prior to UsersMixin is included, it depends on @user
      include Foreman::Controller::UsersMixin
      include Foreman::Controller::Parameters::User
      include Api::Version2

      wrap_parameters User, :include => user_params_filter.accessible_attributes(
        Foreman::Controller::Parameters::User::Context.new(:api, controller_name, nil, false)) +
        ['compute_attributes']

      before_action :find_optional_nested_object

      api :GET, "/users/", N_("List all users")
      api :GET, "/auth_source_ldaps/:auth_source_ldap_id/users", N_("List all users for LDAP authentication source")
      api :GET, "/auth_source_externals/:auth_source_external_id/users", N_("List all users for external authentication source")
      api :GET, "/usergroups/:usergroup_id/users", N_("List all users for user group")
      api :GET, "/roles/:role_id/users", N_("List all users for role")
      api :GET, "/locations/:location_id/users", N_("List all users for location")
      api :GET, "/organizations/:organization_id/users", N_("List all users for organization")
      param :auth_source_ldap_id, String, :desc => N_("ID of LDAP authentication source")
      param :usergroup_id, String, :desc => N_("ID of user group")
      param :role_id, String, :desc => N_("ID of role")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(User)

      def index
        @users = resource_scope_for_index
      end

      api :GET, "/users/:id/", N_("Show a user")
      param :id, String, :required => true

      def show
      end

      api :GET, "/current_user", N_("Show the currently logged-in user")

      def show_current
        @user = User.current
        render :show
      end

      def_param_group :user_params do
        param :login, String, :required => true
        param :firstname, String, :required => false
        param :lastname, String, :required => false
        param :mail, String, :required => true
        param :description, String, :required => false
        param :disabled, :bool, :required => false
        param :admin, :bool, :required => false, :desc => N_("is an admin account")
        param :password, String, :desc => N_("Required unless user is in an external authentication source")
        param :default_location_id, Integer
        param :default_organization_id, Integer
        param :auth_source_id, Integer, :required => true
        param :timezone, ActiveSupport::TimeZone.all.map(&:name), :required => false, :desc => N_("User's timezone")
        param :locale, FastGettext.available_locales, :required => false, :desc => N_("User's preferred locale")
        param :role_ids, Array, :require => false
        param :mail_enabled, :bool, :desc => N_("Enable user E-mail")
        param_group :taxonomies, ::Api::V2::BaseController
      end

      def_param_group :user do
        param :user, Hash, :required => true, :action_aware => true do
          param_group :user_params
        end
      end

      def_param_group :user_update do
        param :user, Hash, :required => true, :action_aware => true do
          param_group :user_params
          param :current_password, String, :desc => N_("Required when user want to change own password")
        end
      end

      api :POST, "/users/", N_("Create a user")
      description <<-DOC
        Adds role 'Default role' to the user by default
      DOC
      param_group :user, :as => :create

      def create
        @user = User.new(user_params)
        if @user.save
          process_success
        else
          process_resource_error
        end
      end

      api :PUT, "/users/:id/", N_("Update a user")
      description <<-DOC
        Adds role 'Default role' to the user if it is not already present.
        Only another admin can change the admin account attribute.
      DOC
      param :id, String, :required => true
      param_group :user_update

      def update
        if @user.update(user_params)
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

      private

      def find_resource
        editing_self? ? @user = User.find(User.current.id) : super
      end

      def allowed_nested_id
        %w(auth_source_ldap_id role_id location_id organization_id usergroup_id)
      end

      def parameter_filter_context
        Foreman::Controller::Parameters::User::Context.new(:api, controller_name, params[:action], editing_self?)
      end
    end
  end
end
