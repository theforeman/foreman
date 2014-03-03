module Api
  module V2
    class RolesController < V2::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/roles/", "List all roles."
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @roles = Role.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/roles/:id/", "Show an role."
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :role do
        param :role, Hash, :action_aware => true do
          param :name, String, :required => true
        end
      end

      api :POST, "/roles/", "Create an role."
      param_group :role, :as => :create

      def create
        @role = Role.new(params[:role])
        process_response @role.save
      end

      api :PUT, "/roles/:id/", "Update an role."
      param :id, String, :required => true
      param_group :role

      def update
        process_response @role.update_attributes(params[:role])
      end

      api :DELETE, "/roles/:id/", "Delete an role."
      param :id, String, :required => true

      def destroy
        process_response @role.destroy
      end
    end
  end
end
