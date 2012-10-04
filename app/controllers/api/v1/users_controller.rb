module Api
  module V1
    class UsersController < BaseController
      include Foreman::Controller::AutoCompleteSearch
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/users/", "List all users."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @users = User.search_for(params[:search], :order => params[:order]).
            paginate :page => params[:page]
      end

      api :GET, "/users/:id/", "Show an user."
      param :id, :number, :required => true
      def show
      end

      api :POST, "/users/", "Create an user."
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
      description <<-DOC
        Adds role 'Anonymous' to the user if it is not already present.
        Only admin can set admin account.
      DOC
      param :id, :number, :required => true
      param :user, Hash, :required => true do
        param :login, String, :required => false
        param :firstname, String, :required => false
        param :lastname, String, :required => false
        param :mail, String, :required => false
        param :admin, :bool, :required => false, :desc => "Is an admin account?"
        param :password, String, :required => true
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
      param :id, :number, :required => true
      def destroy
        if @user == User.current
          deny_access "You are trying to delete your own account"
        else
          process_response @user.destroy
        end
      end
    end
  end
end
