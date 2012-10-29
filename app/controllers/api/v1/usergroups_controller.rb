module Api
  module V1
    class UsergroupsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/usergroups/", "List all usergroups."
      def index
        @usergroups = Usergroup.paginate(:page => params[:page])
      end

      api :GET, "/usergroups/:id/", "Show a usergroup."
      param :id, :identifier, :required => true
      def show
      end

    end
  end
end
