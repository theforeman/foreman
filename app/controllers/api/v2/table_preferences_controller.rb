module Api
  module V2
    class TablePreferencesController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::UserAware
      before_action :check_user
      before_action :find_resource, :only => [:destroy, :update, :show]

      api :GET, "/users/:user_id/table_preferences", N_("List of table preferences for a user")
      param :user_id, String, :desc => N_("ID of the user"), :required => true
      param_group :search_and_pagination, ::Api::V2::BaseController
      def index
        @table_preferences = @user.table_preferences
      end

      api :GET, "/users/:user_id/table_preferences/:name", N_("Table preference details of a given table")
      param :user_id, String, :desc => N_("ID of the user"), :required => true
      param :name, String, :desc => N_("Name of the table"), :required => true
      def show
        if @table_preference.blank?
          @table_preference = TablePreference.new(:user => @user, :name => params[:name])
        end
      end

      def_param_group :table_preference do
        param :user_id, String, :desc => N_('ID of the user'), :required => true
        param :name, String, :desc => N_("Name of the table"), :required => true
        param :columns, Array, :desc => N_("List of user selected columns")
      end

      api :POST, "/users/:user_id/table_preferences/", N_("Creates a table preference for a given table")
      param_group :table_preference
      def create
        @table_preference = @user.table_preferences.build(:name => params[:name], :columns => params[:columns])
        process_response @table_preference.save
      end

      api :PUT, "/users/:user_id/table_preferences/:name", N_("Updates a table preference for a given table")
      param_group :table_preference
      def update
        process_response @table_preference.update(:columns => params[:columns])
      end

      api :DELETE, "/users/:user_id/table_preferences/:name/", N_("Delete a table preference for a given table")
      param :user_id, String, :desc => N_("ID of the user"), :required => true
      param :name, String, :required => true, :desc => N_("Name of the table")
      def destroy
        process_response @table_preference.destroy
      end

      private

      def check_user
        deny_access N_("You are trying access the preferences of a different user") if @user != User.current
      end

      def resource_class
        TablePreference
      end
    end
  end
end
