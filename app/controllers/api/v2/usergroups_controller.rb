module Api
  module V2
    class UsergroupsController < V2::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/usergroups/", "List all user groups."
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"

      def index
        @usergroups = Usergroup.
          authorized(:view_usergroups).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/usergroups/:id/", "Show a user group."
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :usergroup do
        param :name, String, :required => true, :action_aware => true
        param :user_ids, Array, :require => false
        param :usergroup_ids, Array, :require => false
        param :role_ids, Array, :require => false
      end

      api :POST, "/usergroups/", "Create a user group."
      param_group :usergroup, :as => :create

      def create
        @usergroup = Usergroup.new(params[:usergroup])
        process_response @usergroup.save
      end

      api :PUT, "/usergroups/:id/", "Update a user group."
      param :id, String, :required => true
      param_group :usergroup

      def update
        process_response @usergroup.update_attributes(params[:usergroup])
      end

      api :DELETE, "/usergroups/:id/", "Delete a user group."
      param :id, String, :required => true

      def destroy
        process_response @usergroup.destroy
      end

    end
  end
end
