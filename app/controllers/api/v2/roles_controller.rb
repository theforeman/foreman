module Api
  module V2
    class RolesController < V2::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/roles/", "List all roles."
      param :search, String, :desc => "Filter results", :required => false
      param :order, String, :desc => "Sort results", :required => false
      param :page, String, :desc => "paginate results", :required => false
      param :per_page, String, :desc => "number of entries per request", :required => false

      def index
        @roles = Role.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/roles/:id/", "Show an role."
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :role do
        param :name, String, :required => true, :action_aware => true
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
