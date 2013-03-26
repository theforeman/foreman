module Api
  module V1
    class UsersController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/users/", "List all users."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @users = User.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/users/:id/", "Show an user."
      param :id, String, :required => true

      def show
        @user
      end

      api :POST, "/users/", "Create an user."
      # TRANSLATORS: API documentation - do not translate
      description <<-DOC
        Adds role 'Anonymous' to the user by default
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
        @user       = User.new(params[:user])
        @user.admin = params[:user][:admin]
        if @user.save
          @user.roles << Role.find_by_name("Anonymous") unless @user.roles.map(&:name).include? "Anonymous"
          process_success
        else
          process_resource_error
        end
      end

      api :PUT, "/users/:id/", "Update an user."
      # TRANSLATORS: API documentation - do not translate
      description <<-DOC
        Adds role 'Anonymous' to the user if it is not already present.
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
        admin = params[:user].has_key?(:admin) ? params[:user].delete(:admin) : nil
        # Remove keys for restricted variables when the user is editing their own account
        if @user == User.current
          for key in params[:user].keys
            params[:user].delete key unless %w{password_confirmation password mail firstname lastname}.include? key
          end
        end
        if @user.update_attributes(params[:user])
          # Only an admin can update admin attribute of another use
          # this is required, as the admin field is blacklisted above
          @user.update_attribute(:admin, admin) if User.current.admin and !admin.nil?
          @user.roles << Role.find_by_name("Anonymous") unless @user.roles.map(&:name).include? "Anonymous"
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
    end

    private
    def resource_identifying_attributes
      %w( id login)
    end

  end
end
