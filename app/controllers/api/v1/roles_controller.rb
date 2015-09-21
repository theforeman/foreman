module Api
  module V1
    class RolesController < V1::BaseController
      before_filter :require_admin
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

      api :POST, "/roles/", "Create an role."
      param :role, Hash, :required => true do
        param :name, String, :required => true
      end

      def create
        @role = Role.new(foreman_params)
        process_response @role.save
      end

      api :PUT, "/roles/:id/", "Update an role."
      param :id, String, :required => true
      param :role, Hash, :required => true do
        param :name, String
      end

      def update
        process_response @role.update_attributes(foreman_params)
      end

      api :DELETE, "/roles/:id/", "Delete an role."
      param :id, String, :required => true

      def destroy
        process_response @role.destroy
      end
    end
  end
end
