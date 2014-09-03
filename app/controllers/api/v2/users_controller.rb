module Api
  module V2
    class UsersController < V2::BaseController

      wrap_parameters User, :include => (User.attribute_names + ['password'])

      before_filter :find_resource, :only => %w{show update destroy}
      include Foreman::Controller::UsersMixin
      include Api::Version2
      include Api::TaxonomyScope

      api :GET, "/users/", N_("List all users")
      param :search, String, :desc => N_("filter results")
      param :order, String, :desc => N_("sort results")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @users = User.
          authorized(:view_users).except_hidden.
          search_for(*search_options).paginate(paginate_options)
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

      protected
      def resource_identifying_attributes
        %w(login id)
      end

    end
  end
end
