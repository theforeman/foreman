module Api
  module V1
    class UsersController < V1::BaseController
      before_action :find_resource, :only => %w{show update destroy}
      # find_resource needs to be defined prior to UsersMixin is included, it depends on @user
      include Foreman::Controller::UsersMixin
      include Foreman::Controller::Parameters::User

      api :GET, "/users/", "List all users."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @users = User.
          authorized(:view_users).except_hidden.
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/users/:id/", "Show an user."
      param :id, String, :required => true

      def show
      end

      api :POST, "/users/", "Create an user."
      # TRANSLATORS: API documentation - do not translate
      description <<-DOC
        Adds role 'Default role' to the user by default
      DOC
      param :user, Hash, :required => true do
        param :login, String, :required => true
        param :firstname, String, :required => false
        param :lastname, String, :required => false
        param :mail, String, :required => true
        param :admin, :bool, :required => false, :desc => "Is an admin account?"
        param :password, String, :required => true
        param :auth_source_id, Integer, :required => true
      end

      def create
        @user = User.new(user_params)
        if @user.save
          process_success
        else
          process_resource_error
        end
      end

      api :PUT, "/users/:id/", "Update an user."
      # TRANSLATORS: API documentation - do not translate
      description <<-DOC
        Adds role 'Default role' to the user if it is not already present.
        Only admin can set admin account.
      DOC
      param :id, String, :required => true
      param :user, Hash, :required => true do
        param :login, String
        param :firstname, String, :allow_nil => true
        param :lastname, String, :allow_nil => true
        param :mail, String
        param :admin, :bool, :desc => "Is an admin account?"
        param :password, String
      end

      def update
        if @user.update_attributes(user_params)
          update_sub_hostgroups_owners

          process_success
        else
          process_resource_error
        end
      end

      api :DELETE, "/users/:id/", "Delete an user."
      param :id, String, :required => true

      def destroy
        if @user == User.current
          deny_access "You are trying to delete your own account"
        else
          process_response @user.destroy
        end
      end

      private

      def find_resource
        editing_self? ? @user = User.find(User.current.id) : super
      end

      def parameter_filter_context
        Foreman::Controller::Parameters::User::Context.new(:api, controller_name, params[:action], editing_self?)
      end
    end
  end
end
