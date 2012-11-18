module Api
  module V1
    class UsergroupsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/usergroups/", "List all usergroups."
      param :page,  String, :desc => "paginate results"
      def index
        @usergroups = Usergroup.paginate(:page => params[:page])
      end

      api :GET, "/usergroups/:id/", "Show a usergroup."
      param :id, :identifier, :required => true
      def show
      end

      api :POST, "/usergroups/", "Create a usergroup."
      param :usergroup, Hash, :required => true do
        param :name, String, :required => true
      end
      def create
        @usergroup = Usergroup.new(params[:usergroup])
        process_response @usergroup.save
      end

      api :PUT, "/usergroups/:id/", "Update a usergroup."
      param :id, String, :required => true
      param :usergroup, Hash, :required => true do
        param :name, String, :required => true
      end
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
