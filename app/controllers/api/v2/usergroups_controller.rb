module Api
  module V2
    class UsergroupsController < V2::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/usergroups/", "List all usergroups."
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"

      def index
        @usergroups = Usergroup.
          authorized(:view_usergroups).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/usergroups/:id/", "Show a usergroup."
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :usergroup do
        param :usergroup, Hash, :action_aware => true do
          param :name, String, :required => true
        end
      end

      api :POST, "/usergroups/", "Create a usergroup."
      param_group :usergroup, :as => :create

      def create
        @usergroup = Usergroup.new(params[:usergroup])
        process_response @usergroup.save
      end

      api :PUT, "/usergroups/:id/", "Update a usergroup."
      param :id, String, :required => true
      param_group :usergroup

      def update
        process_response @usergroup.update_attributes(params[:usergroup])
      end

      api :DELETE, "/usergroups/:id/", "Delete a usergroup."
      param :id, String, :required => true

      def destroy
        process_response @usergroup.destroy
      end

    end
  end
end
