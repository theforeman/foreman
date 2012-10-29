module Api
  module V1
    class RolesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/roles/", "List all roles."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @roles = Role.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
      end

      api :GET, "/roles/:id/", "Show an role."
      param :id, :identifier, :required => true
      def show
      end

      api :POST, "/roles/", "Create an role."
      param :role, Hash, :required => true do
        param :name, String, :required => true
      end
      def create
        @role = Role.new(params[:role])
        process_response @role.save
      end

      api :PUT, "/roles/:id/", "Update an role."
      param :id, String, :required => true
      param :role, Hash, :required => true do
        param :name, String
      end
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
